package com.sirius.web.toolkit.web;

import com.sirius.web.toolkit.api.ApiResponse;
import com.sirius.web.toolkit.api.EchoResponse;
import com.sirius.web.toolkit.context.RequestContext;
import com.sirius.web.toolkit.error.BizException;
import com.sirius.web.toolkit.error.ErrorCode;
import java.time.Instant;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ToolkitController {

    @GetMapping("/api/toolkit/echo")
    public ApiResponse<EchoResponse> echo(@RequestParam String message) {
        return ApiResponse.ok(new EchoResponse(message, Instant.now()), RequestContext.currentRequestId());
    }

    @GetMapping("/api/toolkit/fail")
    public ApiResponse<Void> fail() {
        throw new BizException(ErrorCode.INVALID_REQUEST, "demonstration failure");
    }
}

