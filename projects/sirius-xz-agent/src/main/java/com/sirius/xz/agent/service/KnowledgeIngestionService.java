package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.persistence.KnowledgeChunkRow;
import com.sirius.xz.agent.persistence.PgVectorStore;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class KnowledgeIngestionService {

    private final KnowledgeBase knowledgeBase;
    private final ChunkingService chunkingService;
    private final EmbeddingService embeddingService;
    private final PgVectorStore vectorStore;

    public KnowledgeIngestionService(
        KnowledgeBase knowledgeBase,
        ChunkingService chunkingService,
        EmbeddingService embeddingService,
        PgVectorStore vectorStore
    ) {
        this.knowledgeBase = knowledgeBase;
        this.chunkingService = chunkingService;
        this.embeddingService = embeddingService;
        this.vectorStore = vectorStore;
    }

    public KnowledgeDocument upsert(KnowledgeDocument document) {
        knowledgeBase.upsert(document);
        vectorStore.deleteByDocumentId(document.id());
        vectorStore.saveAll(chunkingService.chunk(document).stream()
            .map(chunk -> new KnowledgeChunkRow(
                chunk.documentId(),
                chunk.documentTitle(),
                chunk.chunkIndex(),
                chunk.chunkText(),
                chunk.tags(),
                embeddingService.embed(chunk.chunkText())
            ))
            .toList());
        return document;
    }
}
