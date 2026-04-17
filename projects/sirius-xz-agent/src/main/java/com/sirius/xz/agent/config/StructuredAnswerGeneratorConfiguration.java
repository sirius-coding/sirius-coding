package com.sirius.xz.agent.config;

import com.sirius.xz.agent.service.LocalStructuredAnswerGenerator;
import com.sirius.xz.agent.service.StructuredAnswerGenerator;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
public class StructuredAnswerGeneratorConfiguration {

    @Bean
    @ConditionalOnMissingBean(StructuredAnswerGenerator.class)
    public StructuredAnswerGenerator localStructuredAnswerGenerator() {
        return new LocalStructuredAnswerGenerator();
    }
}
