package st02.monitor;

import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;

/** Autoriza al sitio (otro origen) a leer las respuestas desde el navegador. */
@Provider
public class CorsFiltro implements ContainerResponseFilter {

    private static final String ORIGEN = System.getenv().getOrDefault("ORIGEN_PERMITIDO", "*");

    @Override
    public void filter(ContainerRequestContext peticion, ContainerResponseContext respuesta) {
        respuesta.getHeaders().putSingle("Access-Control-Allow-Origin", ORIGEN);
        respuesta.getHeaders().putSingle("Vary", "Origin");
    }
}
