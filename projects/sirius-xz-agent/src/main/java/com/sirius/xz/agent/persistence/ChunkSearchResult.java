package com.sirius.xz.agent.persistence;

import java.util.List;

public record ChunkSearchResult(
    String documentId,
    String documentTitle,
    int chunkIndex,
    String chunkText,
    List<String> tags,
    double similarity
) {
}
