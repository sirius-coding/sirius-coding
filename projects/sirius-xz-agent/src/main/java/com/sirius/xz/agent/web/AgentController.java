package com.sirius.xz.agent.web;

import com.sirius.xz.agent.service.AgentAnswer;
import com.sirius.xz.agent.service.AgentService;
import jakarta.validation.constraints.NotBlank;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AgentController {

    private final AgentService agentService;

    public AgentController(AgentService agentService) {
        this.agentService = agentService;
    }

    @GetMapping("/api/agent/summary")
    public Map<String, Object> summary(@RequestParam(defaultValue = "Sirius") String name) {
        return Map.of(
            "name", name,
            "position", "Java Senior Engineer",
            "focus", new String[] {"Spring", "RAG", "Agent", "Microservices"}
        );
    }

    @GetMapping("/api/agent/ask")
    public AgentAnswer ask(@RequestParam @NotBlank String question) {
        return agentService.answer(question);
    }
}

