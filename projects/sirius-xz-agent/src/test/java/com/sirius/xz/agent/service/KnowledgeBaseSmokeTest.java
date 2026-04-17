package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;

public final class KnowledgeBaseSmokeTest {

    private KnowledgeBaseSmokeTest() {
    }

    public static void main(String[] args) {
        InMemoryKnowledgeBase knowledgeBase = new InMemoryKnowledgeBase(List.of(
            new KnowledgeDocument("doc-1", "Doc 1", "first", List.of("alpha")),
            new KnowledgeDocument("doc-2", "Doc 2", "second", List.of("beta"))
        ));

        if (knowledgeBase.documents().size() != 2) {
            throw new IllegalStateException("Expected two seed documents");
        }

        knowledgeBase.upsert(new KnowledgeDocument("doc-2", "Doc 2 Updated", "second updated", List.of("beta", "updated")));

        KnowledgeDocument updated = knowledgeBase.findById("doc-2")
            .orElseThrow(() -> new IllegalStateException("Expected doc-2 to exist"));

        if (!"Doc 2 Updated".equals(updated.title())) {
            throw new IllegalStateException("Expected upsert to replace the document");
        }
    }
}

