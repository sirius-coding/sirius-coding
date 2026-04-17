package com.sirius.xz.agent.config;

import com.sirius.xz.agent.service.DeepSeekStructuredAnswerGenerator;
import com.sirius.xz.agent.service.StructuredAnswerGenerator;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.deepseek.DeepSeekChatModel;
import org.springframework.ai.deepseek.DeepSeekChatOptions;
import org.springframework.ai.deepseek.api.DeepSeekApi;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
@EnableConfigurationProperties(DeepSeekProperties.class)
public class DeepSeekConfiguration {

    @Bean
    @ConditionalOnProperty(prefix = "sirius.ai.deepseek", name = "enabled", havingValue = "true")
    public ChatModel deepSeekChatModel(DeepSeekProperties properties) {
        if (properties.apiKey() == null || properties.apiKey().isBlank()) {
            throw new IllegalStateException("sirius.ai.deepseek.api-key must be set when enabled");
        }
        DeepSeekApi api = DeepSeekApi.builder()
            .apiKey(properties.apiKey())
            .baseUrl(defaultIfBlank(properties.baseUrl(), "https://api.deepseek.com"))
            .build();

        DeepSeekChatOptions.Builder options = DeepSeekChatOptions.builder()
            .model(defaultIfBlank(properties.model(), "deepseek-chat"));

        if (properties.temperature() != null) {
            options.temperature(properties.temperature());
        }
        if (properties.maxTokens() != null) {
            options.maxTokens(properties.maxTokens());
        }

        return DeepSeekChatModel.builder()
            .deepSeekApi(api)
            .defaultOptions(options.build())
            .build();
    }

    @Bean
    @ConditionalOnProperty(prefix = "sirius.ai.deepseek", name = "enabled", havingValue = "true")
    public StructuredAnswerGenerator deepSeekStructuredAnswerGenerator(ChatModel chatModel) {
        return new DeepSeekStructuredAnswerGenerator(chatModel);
    }

    private String defaultIfBlank(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }
}
