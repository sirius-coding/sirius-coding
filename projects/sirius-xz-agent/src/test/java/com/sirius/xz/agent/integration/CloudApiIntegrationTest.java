package com.sirius.xz.agent.integration;

import static org.assertj.core.api.Assertions.assertThat;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.service.AgentAnswer;
import com.sirius.xz.agent.web.KnowledgeController;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, properties = {
    "sirius.vectorstore.enabled=true",
    "sirius.ai.deepseek.enabled=false",
    "spring.flyway.baseline-on-migrate=true",
    "spring.flyway.baseline-version=0"
})
@EnabledIfEnvironmentVariable(named = "SIRIUS_CLOUD_IT_ENABLED", matches = "true")
class CloudApiIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @DynamicPropertySource
    static void registerDataSource(DynamicPropertyRegistry registry) {
        String port = System.getenv().getOrDefault("SIRIUS_CLOUD_IT_PORT", "15432");
        registry.add("spring.datasource.url", () -> "jdbc:postgresql://127.0.0.1:" + port + "/sirius_xz_agent");
        registry.add("spring.datasource.username", () -> System.getenv().getOrDefault("SIRIUS_CLOUD_IT_USERNAME", "sirius"));
        registry.add("spring.datasource.password", () -> System.getenv().getOrDefault("SIRIUS_CLOUD_IT_PASSWORD", "sirius"));
    }

    @Test
    void knowledgeAndAskApisWorkAgainstRealPgVector() {
        KnowledgeController.KnowledgeDocumentRequest request = new KnowledgeController.KnowledgeDocumentRequest(
            "rag-playbook",
            "RAG Playbook",
            "RAG grounds answers with retrieval before generation and keeps model output tied to internal knowledge.",
            List.of("rag", "retrieval")
        );

        ResponseEntity<KnowledgeDocument> created = restTemplate.postForEntity(
            baseUrl() + "/api/knowledge/documents",
            request,
            KnowledgeDocument.class
        );

        assertThat(created.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(created.getBody()).isNotNull();
        assertThat(created.getBody().id()).isEqualTo("rag-playbook");

        ResponseEntity<KnowledgeDocument[]> documents = restTemplate.getForEntity(
            baseUrl() + "/api/knowledge/documents",
            KnowledgeDocument[].class
        );

        assertThat(documents.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(documents.getBody()).isNotNull();
        assertThat(documents.getBody()).extracting(KnowledgeDocument::id)
            .contains("rag-playbook");

        ResponseEntity<AgentAnswer> answer = restTemplate.getForEntity(
            baseUrl() + "/api/agent/ask?question=How does retrieval keep RAG grounded?",
            AgentAnswer.class
        );

        assertThat(answer.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(answer.getBody()).isNotNull();
        assertThat(answer.getBody().sources()).extracting(KnowledgeDocument::id)
            .contains("rag-playbook");
        assertThat(answer.getBody().matchedTokens()).contains("rag");
        assertThat(answer.getBody().answer()).contains("RAG Playbook");
    }

    private String baseUrl() {
        return "http://127.0.0.1:" + port;
    }
}
