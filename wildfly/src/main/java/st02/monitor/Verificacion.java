package st02.monitor;

/** Resultado de comprobar un servicio. JSON-B serializa sus campos públicos. */
public class Verificacion {

    public String servicio;
    public boolean ok;
    public int milisegundos;
    public String detalle;

    public Verificacion() {
    }

    public Verificacion(String servicio, boolean ok, int milisegundos, String detalle) {
        this.servicio = servicio;
        this.ok = ok;
        this.milisegundos = milisegundos;
        this.detalle = detalle;
    }
}
