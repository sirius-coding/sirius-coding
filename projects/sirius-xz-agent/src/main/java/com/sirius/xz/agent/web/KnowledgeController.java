package com.sirius.xz.agent.web;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import com.sirius.xz.agent.service.KnowledgeBase;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/knowledge")
public class KnowledgeController {

    private final KnowledgeBase knowledgeBase;

    public KnowledgeController(KnowledgeBase knowledgeBase) {
        this.knowledgeBase = knowledgeBase;
    }

    @GetMapping("/documents")
    public List<KnowledgeDocument> documents() {
        return knowledgeBase.documents();
    }

    @GetMapping("/documents/{id}")
    public ResponseEntity<KnowledgeDocument> document(@PathVariable String id) {
        return knowledgeBase.findById(id)
            .map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/documents")
    public KnowledgeDocument upsert(@RequestBody @Valid KnowledgeDocumentRequest request) {
        KnowledgeDocument document = new KnowledgeDocument(
            request.id(),
            request.title(),
            request.content(),
            request.tags()
        );
        knowledgeBase.upsert(document);
        return document;
    }

    public record KnowledgeDocumentRequest(
        @NotBlank String id,
        @NotBlank String title,
        @NotBlank String content,
        @NotEmpty List<@NotBlank String> tags
    ) {
    }
}
