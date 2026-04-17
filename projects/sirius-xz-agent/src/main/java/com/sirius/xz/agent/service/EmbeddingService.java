package com.sirius.xz.agent.service;

public interface EmbeddingService {

    float[] embed(String text);

    int dimensions();
}
