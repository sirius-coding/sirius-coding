package com.sirius.cloud.starter;

import com.sirius.cloud.starter.config.CloudStarterProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan(basePackageClasses = CloudStarterProperties.class)
public class SiriusCloudStarterApplication {

    public static void main(String[] args) {
        SpringApplication.run(SiriusCloudStarterApplication.class, args);
    }
}

