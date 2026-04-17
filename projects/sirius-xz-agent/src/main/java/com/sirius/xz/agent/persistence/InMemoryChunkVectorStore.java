package com.sirius.xz.agent.persistence;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class InMemoryChunkVectorStore implements PgVectorStore {

    private final CopyOnWriteArrayList<KnowledgeChunkRow> rows = new CopyOnWriteArrayList<>();

    @Override
    public void save(KnowledgeChunkRow row) {
        deleteByChunk(row.documentId(), row.chunkIndex());
        rows.add(row);
    }

    @Override
    public void saveAll(List<KnowledgeChunkRow> rows) {
        rows.forEach(this::save);
    }

    @Override
    public List<ChunkSearchResult> search(float[] queryVector, int limit) {
        List<ChunkSearchResult> hits = new ArrayList<>();
        for (KnowledgeChunkRow row : rows) {
            hits.add(new ChunkSearchResult(
                row.documentId(),
                row.documentTitle(),
                row.chunkIndex(),
                row.chunkText(),
                row.tags(),
                PgVectorSql.cosineSimilarity(queryVector, row.embedding())
            ));
        }
        return hits.stream()
            .sorted(Comparator.comparingDouble(ChunkSearchResult::similarity).reversed())
            .limit(limit)
            .toList();
    }

    @Override
    public void deleteByDocumentId(String documentId) {
        rows.removeIf(row -> row.documentId().equals(documentId));
    }

    private void deleteByChunk(String documentId, int chunkIndex) {
        rows.removeIf(row -> row.documentId().equals(documentId) && row.chunkIndex() == chunkIndex);
    }
}
