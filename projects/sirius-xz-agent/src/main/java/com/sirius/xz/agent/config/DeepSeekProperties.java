package com.sirius.xz.agent.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "sirius.ai.deepseek")
public record DeepSeekProperties(
    boolean enabled,
    String apiKey,
    String baseUrl,
    String model,
    Double temperature,
    Integer maxTokens
) {
}
