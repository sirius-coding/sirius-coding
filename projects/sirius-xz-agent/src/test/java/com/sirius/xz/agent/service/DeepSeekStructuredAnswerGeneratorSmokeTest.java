package com.sirius.xz.agent.service;

import com.sirius.xz.agent.domain.KnowledgeDocument;
import java.util.List;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.model.Generation;
import org.springframework.ai.chat.prompt.Prompt;

public final class DeepSeekStructuredAnswerGeneratorSmokeTest {

    private DeepSeekStructuredAnswerGeneratorSmokeTest() {
    }

    public static void main(String[] args) {
        CapturingChatModel chatModel = new CapturingChatModel("DeepSeek says hello");
        DeepSeekStructuredAnswerGenerator generator = new DeepSeekStructuredAnswerGenerator(chatModel);
        List<KnowledgeSearchResult> results = List.of(
            new KnowledgeSearchResult(
                new KnowledgeDocument(
                    "rag-playbook",
                    "RAG Playbook",
                    "RAG combines retrieval with generation so answers stay grounded in internal knowledge.",
                    List.of("rag", "knowledge")
                ),
                9,
                List.of("rag", "knowledge")
            )
        );

        String answer = generator.generate("How does RAG keep answers grounded?", results);
        if (!"DeepSeek says hello".equals(answer)) {
            throw new IllegalStateException("Expected DeepSeek answer to be returned");
        }
        if (chatModel.lastPrompt == null || !chatModel.lastPrompt.getContents().contains("RAG Playbook")) {
            throw new IllegalStateException("Expected prompt to include retrieval context");
        }
    }

    private static final class CapturingChatModel implements ChatModel {
        private final String response;
        private Prompt lastPrompt;

        private CapturingChatModel(String response) {
            this.response = response;
        }

        @Override
        public ChatResponse call(Prompt prompt) {
            lastPrompt = prompt;
            return new ChatResponse(List.of(new Generation(new AssistantMessage(response))));
        }
    }
}
