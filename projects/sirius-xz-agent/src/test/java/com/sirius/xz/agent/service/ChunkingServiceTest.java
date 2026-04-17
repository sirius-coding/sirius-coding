package com.sirius.xz.agent.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.sirius.xz.agent.domain.DocumentChunk;
import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;
import org.junit.jupiter.api.Test;

class ChunkingServiceTest {

    public static void main(String[] args) {
        new ChunkingServiceTest().chunkingSplitsLongTextIntoOrderedChunks();
    }

    @Test
    void chunkingSplitsLongTextIntoOrderedChunks() {
        ChunkingService service = new ChunkingService(24);
        List<DocumentChunk> chunks = service.chunk(
            new KnowledgeDocument(
                "doc-1",
                "RAG Playbook",
                "alpha beta gamma delta epsilon zeta eta theta iota kappa",
                List.of("rag")
            )
        );

        assertThat(chunks).hasSizeGreaterThan(1);
        assertThat(chunks.get(0).chunkIndex()).isZero();
        assertThat(chunks.get(0).documentId()).isEqualTo("doc-1");
        assertThat(chunks.get(0).documentTitle()).isEqualTo("RAG Playbook");
        assertThat(chunks.get(0).tags()).containsExactly("rag");
    }
}
