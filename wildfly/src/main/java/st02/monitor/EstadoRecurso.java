package st02.monitor;

import jakarta.annotation.Resource;
import jakarta.enterprise.context.RequestScoped;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import javax.sql.DataSource;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.Duration;
import java.util.List;
import java.util.logging.Logger;

/**
 * GET /monitor/api/estado
 * Comprueba SQL Server (DataSource JNDI), FastAPI y CodeIgniter (HTTP),
 * registra los resultados en la tabla verificaciones y los devuelve como JSON.
 */
@Path("/estado")
@RequestScoped
public class EstadoRecurso {

    private static final Logger LOG = Logger.getLogger(EstadoRecurso.class.getName());
    private static final Duration LIMITE = Duration.ofSeconds(3);
    private static final HttpClient HTTP = HttpClient.newBuilder().connectTimeout(LIMITE).build();

    // El servidor crea el pool (configurar.cli) y lo inyecta por su nombre JNDI
    @Resource(lookup = "java:jboss/datasources/Stack02DS")
    private DataSource baseDatos;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<Verificacion> estado() {
        List<Verificacion> resultado = List.of(
                verificarBaseDatos(),
                verificarHttp("fastapi", entorno("FASTAPI_URL", "http://fastapi:8000") + "/salud"),
                verificarHttp("codeigniter4", entorno("CODEIGNITER_URL", "http://codeigniter") + "/salud"),
                new Verificacion("wildfly", true, 0, "Java " + Runtime.version()));
        registrar(resultado);
        return resultado;
    }

    private Verificacion verificarBaseDatos() {
        long inicio = System.nanoTime();
        try (Connection conexion = baseDatos.getConnection();
             Statement sentencia = conexion.createStatement();
             ResultSet filas = sentencia.executeQuery("SELECT @@VERSION")) {
            filas.next();
            String version = filas.getString(1).lines().findFirst().orElse("").trim();
            return new Verificacion("sqlserver", true, ms(inicio), version);
        } catch (SQLException e) {
            return new Verificacion("sqlserver", false, ms(inicio), e.getMessage());
        }
    }

    private Verificacion verificarHttp(String servicio, String url) {
        long inicio = System.nanoTime();
        try {
            HttpRequest peticion = HttpRequest.newBuilder(URI.create(url)).timeout(LIMITE).GET().build();
            HttpResponse<String> respuesta = HTTP.send(peticion, HttpResponse.BodyHandlers.ofString());
            boolean ok = respuesta.statusCode() == 200;
            return new Verificacion(servicio, ok, ms(inicio), "HTTP " + respuesta.statusCode() + " " + url);
        } catch (IOException e) {
            return new Verificacion(servicio, false, ms(inicio), e.getClass().getSimpleName() + " " + url);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return new Verificacion(servicio, false, ms(inicio), "Interrumpido");
        }
    }

    /** Guarda las verificaciones en un solo lote. Si la base no responde, solo lo anota en el log. */
    private void registrar(List<Verificacion> verificaciones) {
        String sql = "INSERT INTO verificaciones (servicio, ok, milisegundos, detalle) VALUES (?, ?, ?, ?)";
        try (Connection conexion = baseDatos.getConnection();
             PreparedStatement insercion = conexion.prepareStatement(sql)) {
            for (Verificacion v : verificaciones) {
                insercion.setString(1, v.servicio);
                insercion.setBoolean(2, v.ok);
                insercion.setInt(3, v.milisegundos);
                insercion.setString(4, recortar(v.detalle, 400));
                insercion.addBatch();
            }
            insercion.executeBatch();
        } catch (SQLException e) {
            LOG.warning("No se pudieron registrar las verificaciones: " + e.getMessage());
        }
    }

    private static int ms(long inicio) {
        return (int) ((System.nanoTime() - inicio) / 1_000_000);
    }

    private static String entorno(String nombre, String porDefecto) {
        return System.getenv().getOrDefault(nombre, porDefecto);
    }

    private static String recortar(String texto, int maximo) {
        return texto == null || texto.length() <= maximo ? texto : texto.substring(0, maximo);
    }
}
