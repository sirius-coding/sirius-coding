package com.sirius.xz.agent.web;

import com.sirius.xz.agent.service.AgentSummaryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AgentController {

    private final AgentSummaryService service;

    public AgentController(AgentSummaryService service) {
        this.service = service;
    }

    @GetMapping("/api/agent/summary")
    public String summary(@RequestParam(defaultValue = "Sirius") String name) {
        return service.buildSummary(name);
    }
}

