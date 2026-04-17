package com.sirius.xz.agent.service;

import java.util.List;

public interface StructuredAnswerGenerator {

    String generate(String question, List<KnowledgeSearchResult> results);
}
