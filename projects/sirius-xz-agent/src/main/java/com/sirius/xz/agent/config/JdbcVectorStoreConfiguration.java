package com.sirius.xz.agent.config;

import com.sirius.xz.agent.persistence.JdbcPgVectorStore;
import com.sirius.xz.agent.persistence.PgVectorStore;
import javax.sql.DataSource;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration(proxyBeanMethods = false)
@ConditionalOnProperty(prefix = "sirius.vectorstore", name = "enabled", havingValue = "true")
public class JdbcVectorStoreConfiguration {

    @Bean
    @Primary
    public PgVectorStore jdbcPgVectorStore(DataSource dataSource) {
        return new JdbcPgVectorStore(new JdbcTemplate(dataSource));
    }
}
