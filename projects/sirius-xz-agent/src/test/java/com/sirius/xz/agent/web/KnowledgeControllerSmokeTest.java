package com.sirius.xz.agent.web;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.service.InMemoryKnowledgeBase;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

public final class KnowledgeControllerSmokeTest {

    private KnowledgeControllerSmokeTest() {
    }

    public static void main(String[] args) {
        KnowledgeController controller = new KnowledgeController(new InMemoryKnowledgeBase(List.of(
            new KnowledgeDocument("doc-1", "Doc 1", "first", List.of("alpha"))
        )));

        ResponseEntity<KnowledgeDocument> found = controller.document("doc-1");
        if (found.getStatusCode() != HttpStatus.OK) {
            throw new IllegalStateException("Expected doc-1 to be returned");
        }

        ResponseEntity<KnowledgeDocument> missing = controller.document("missing");
        if (missing.getStatusCode() != HttpStatus.NOT_FOUND) {
            throw new IllegalStateException("Expected missing document to return 404");
        }
    }
}
