package st02.monitor;

import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;

/** Activa Jakarta REST: todos los recursos quedan bajo /monitor/api. */
@ApplicationPath("/api")
public class AplicacionMonitor extends Application {
}
