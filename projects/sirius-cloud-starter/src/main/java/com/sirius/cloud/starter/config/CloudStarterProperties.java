package com.sirius.cloud.starter.config;

import java.util.ArrayList;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "sirius.cloud")
public class CloudStarterProperties {

    private String serviceName = "sirius-cloud-starter";
    private String environment = "local";
    private boolean discoveryEnabled = false;
    private List<String> capabilities = new ArrayList<>(List.of(
        "OpenFeign",
        "Nacos Discovery",
        "Configuration Governance",
        "Gateway Ready"
    ));

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getEnvironment() {
        return environment;
    }

    public void setEnvironment(String environment) {
        this.environment = environment;
    }

    public boolean isDiscoveryEnabled() {
        return discoveryEnabled;
    }

    public void setDiscoveryEnabled(boolean discoveryEnabled) {
        this.discoveryEnabled = discoveryEnabled;
    }

    public List<String> getCapabilities() {
        return capabilities;
    }

    public void setCapabilities(List<String> capabilities) {
        this.capabilities = new ArrayList<>(capabilities);
    }
}

