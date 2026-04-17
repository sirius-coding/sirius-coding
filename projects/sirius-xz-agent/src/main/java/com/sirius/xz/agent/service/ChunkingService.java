package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.DocumentChunk;
import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.ArrayList;
import java.util.List;

public class ChunkingService {

    private final int chunkSize;

    public ChunkingService(int chunkSize) {
        this.chunkSize = chunkSize;
    }

    public List<DocumentChunk> chunk(KnowledgeDocument document) {
        List<String> words = List.of(document.content().trim().split("\\s+"));
        List<DocumentChunk> chunks = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        int chunkIndex = 0;

        for (String word : words) {
            if (current.isEmpty()) {
                current.append(word);
            } else if (current.length() + 1 + word.length() <= chunkSize) {
                current.append(' ').append(word);
            } else {
                chunks.add(new DocumentChunk(
                    document.id(),
                    document.title(),
                    chunkIndex++,
                    current.toString(),
                    document.tags()
                ));
                current = new StringBuilder(word);
            }
        }

        if (!current.isEmpty()) {
            chunks.add(new DocumentChunk(
                document.id(),
                document.title(),
                chunkIndex,
                current.toString(),
                document.tags()
            ));
        }

        return chunks;
    }
}
