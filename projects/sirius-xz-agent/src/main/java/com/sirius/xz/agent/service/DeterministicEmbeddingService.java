package com.sirius.xz.agent.service;

import java.util.Locale;

public class DeterministicEmbeddingService implements EmbeddingService {

    private final int dimensions;

    public DeterministicEmbeddingService(int dimensions) {
        this.dimensions = dimensions;
    }

    @Override
    public float[] embed(String text) {
        float[] vector = new float[dimensions];
        String normalized = text == null ? "" : text.toLowerCase(Locale.ROOT);
        for (String token : normalized.split("[^a-z0-9]+")) {
            if (token.isBlank()) {
                continue;
            }
            int bucket = Math.floorMod(token.hashCode(), dimensions);
            vector[bucket] += 1.0f;
        }
        return vector;
    }

    @Override
    public int dimensions() {
        return dimensions;
    }
}
