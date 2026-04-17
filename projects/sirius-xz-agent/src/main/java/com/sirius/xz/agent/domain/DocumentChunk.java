package com.sirius.xz.agent.domain;

import java.util.List;

public record DocumentChunk(
    String documentId,
    String documentTitle,
    int chunkIndex,
    String chunkText,
    List<String> tags
) {
}
