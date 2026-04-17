package com.sirius.cloud.starter.web;

import com.sirius.cloud.starter.config.CloudStarterProperties;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ServiceInfoController {

    private final CloudStarterProperties properties;

    @Value("${spring.application.name:sirius-cloud-starter}")
    private String applicationName;

    public ServiceInfoController(CloudStarterProperties properties) {
        this.properties = properties;
    }

    @GetMapping("/api/service-info")
    public ServiceInfoResponse serviceInfo() {
        return new ServiceInfoResponse(
            properties.getServiceName(),
            properties.getEnvironment(),
            properties.isDiscoveryEnabled(),
            properties.getCapabilities(),
            applicationName,
            OffsetDateTime.now().toString()
        );
    }

    @GetMapping("/api/health")
    public HealthResponse health() {
        return new HealthResponse("UP", applicationName, OffsetDateTime.now().toString());
    }

    public record ServiceInfoResponse(
        String serviceName,
        String environment,
        boolean discoveryEnabled,
        List<String> capabilities,
        String applicationName,
        String timestamp
    ) {
    }

    public record HealthResponse(
        String status,
        String serviceName,
        String timestamp
    ) {
    }
}

