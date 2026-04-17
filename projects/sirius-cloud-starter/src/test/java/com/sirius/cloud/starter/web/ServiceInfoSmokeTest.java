package com.sirius.cloud.starter.web;

import com.sirius.cloud.starter.config.CloudStarterProperties;
import java.lang.reflect.Field;
import java.util.List;

public final class ServiceInfoSmokeTest {

    private ServiceInfoSmokeTest() {
    }

    public static void main(String[] args) throws Exception {
        CloudStarterProperties properties = new CloudStarterProperties();
        properties.setEnvironment("local");
        properties.setCapabilities(List.of("OpenFeign", "Configuration Governance", "Gateway Ready"));

        ServiceInfoController controller = new ServiceInfoController(properties);
        Field field = ServiceInfoController.class.getDeclaredField("applicationName");
        field.setAccessible(true);
        field.set(controller, "sirius-cloud-starter");

        ServiceInfoController.ServiceInfoResponse response = controller.serviceInfo();

        if (!"sirius-cloud-starter".equals(response.serviceName())) {
            throw new IllegalStateException("Unexpected service name: " + response.serviceName());
        }
        if (response.discoveryEnabled()) {
            throw new IllegalStateException("Discovery must be disabled by default for local runs");
        }
        if (!response.capabilities().contains("OpenFeign")) {
            throw new IllegalStateException("Capabilities should advertise OpenFeign readiness");
        }
        if (!"sirius-cloud-starter".equals(response.applicationName())) {
            throw new IllegalStateException("Unexpected application name: " + response.applicationName());
        }
    }
}

