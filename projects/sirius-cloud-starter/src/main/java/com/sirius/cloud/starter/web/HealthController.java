package com.sirius.cloud.starter.web;

import java.time.OffsetDateTime;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/api/health")
    public Map<String, Object> health() {
        return Map.of(
            "service", "sirius-cloud-starter",
            "status", "UP",
            "time", OffsetDateTime.now().toString()
        );
    }
}

