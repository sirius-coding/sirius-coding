package com.sirius.xz.agent.persistence;

import java.util.List;

public interface PgVectorStore {

    void save(KnowledgeChunkRow row);

    void saveAll(List<KnowledgeChunkRow> rows);

    List<ChunkSearchResult> search(float[] queryVector, int limit);

    void deleteByDocumentId(String documentId);
}
