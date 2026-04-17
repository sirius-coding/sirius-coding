package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.persistence.ChunkSearchResult;
import com.sirius.xz.agent.persistence.PgVectorStore;
import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;

@Service
public class RetrievalService {

    private final KnowledgeBase knowledgeBase;
    private final PgVectorStore vectorStore;
    private final EmbeddingService embeddingService;

    public RetrievalService(KnowledgeBase knowledgeBase) {
        this(knowledgeBase, null, null);
    }

    public RetrievalService(KnowledgeBase knowledgeBase, PgVectorStore vectorStore, EmbeddingService embeddingService) {
        this.knowledgeBase = knowledgeBase;
        this.vectorStore = vectorStore;
        this.embeddingService = embeddingService;
    }

    public List<KnowledgeSearchResult> search(String question, int limit) {
        if (vectorStore != null && embeddingService != null) {
            List<KnowledgeSearchResult> vectorResults = vectorSearch(question, limit);
            if (!vectorResults.isEmpty()) {
                return vectorResults;
            }
        }

        Set<String> questionTokens = tokens(question);
        return knowledgeBase.documents().stream()
            .map(document -> new KnowledgeSearchResult(
                document,
                score(document, questionTokens),
                matchedTokens(document, questionTokens)
            ))
            .filter(result -> result.score() > 0)
            .sorted(Comparator
                .comparingInt(KnowledgeSearchResult::score)
                .reversed()
                .thenComparing(result -> result.document().title().toLowerCase(Locale.ROOT))
                .thenComparing(result -> result.document().id()))
            .limit(limit)
            .collect(Collectors.toList());
    }

    private List<KnowledgeSearchResult> vectorSearch(String question, int limit) {
        float[] queryVector = embeddingService.embed(question);
        List<ChunkSearchResult> hits = vectorStore.search(queryVector, limit * 3);
        Map<String, ChunkSearchResult> bestHitByDocument = new HashMap<>();
        for (ChunkSearchResult hit : hits) {
            bestHitByDocument.merge(
                hit.documentId(),
                hit,
                (existing, candidate) -> candidate.similarity() > existing.similarity() ? candidate : existing
            );
        }

        Set<String> questionTokens = tokens(question);
        return bestHitByDocument.values().stream()
            .sorted(Comparator.comparingDouble(ChunkSearchResult::similarity).reversed())
            .limit(limit)
            .map(hit -> new KnowledgeSearchResult(
                new KnowledgeDocument(
                    hit.documentId(),
                    hit.documentTitle(),
                    hit.chunkText(),
                    hit.tags()
                ),
                Math.max(1, (int) Math.round(hit.similarity() * 10)),
                matchedTokens(hit.chunkText(), hit.tags(), questionTokens)
            ))
            .toList();
    }

    public List<KnowledgeDocument> findRelevantDocuments(String question, int limit) {
        return search(question, limit).stream()
            .map(KnowledgeSearchResult::document)
            .toList();
    }

    int score(KnowledgeDocument document, Set<String> questionTokens) {
        int overlap = 0;
        Set<String> titleTokens = tokens(document.title());
        Set<String> contentTokens = tokens(document.content());
        Set<String> idTokens = tokens(document.id());
        Set<String> tagTokens = document.tags().stream()
            .flatMap(tag -> tokens(tag).stream())
            .collect(Collectors.toCollection(LinkedHashSet::new));

        for (String token : questionTokens) {
            if (titleTokens.contains(token)) {
                overlap += 5;
            }
            if (idTokens.contains(token)) {
                overlap += 3;
            }
            if (tagTokens.contains(token)) {
                overlap += 2;
            }
            if (contentTokens.contains(token)) {
                overlap += 1;
            }
        }
        return overlap;
    }

    List<String> matchedTokens(KnowledgeDocument document, Set<String> questionTokens) {
        Set<String> titleTokens = tokens(document.title());
        Set<String> contentTokens = tokens(document.content());
        Set<String> idTokens = tokens(document.id());
        Set<String> tagTokens = document.tags().stream()
            .flatMap(tag -> tokens(tag).stream())
            .collect(Collectors.toCollection(LinkedHashSet::new));

        return questionTokens.stream()
            .filter(token ->
                titleTokens.contains(token)
                    || contentTokens.contains(token)
                    || idTokens.contains(token)
                    || tagTokens.contains(token)
            )
            .toList();
    }

    List<String> matchedTokens(String chunkText, List<String> tags, Set<String> questionTokens) {
        Set<String> contentTokens = tokens(chunkText);
        Set<String> tagTokens = tags.stream()
            .flatMap(tag -> tokens(tag).stream())
            .collect(Collectors.toCollection(LinkedHashSet::new));

        return questionTokens.stream()
            .filter(token -> contentTokens.contains(token) || tagTokens.contains(token))
            .toList();
    }

    private Set<String> tokens(String text) {
        return Arrays.stream(text.toLowerCase(Locale.ROOT).split("[^a-z0-9]+"))
            .filter(token -> !token.isBlank())
            .collect(Collectors.toCollection(LinkedHashSet::new));
    }
}
