package com.sirius.xz.agent.persistence;

import java.util.List;

public record KnowledgeChunkRow(
    String documentId,
    String documentTitle,
    int chunkIndex,
    String chunkText,
    List<String> tags,
    float[] embedding
) {
}
