package com.sirius.web.toolkit.api;

import java.time.Instant;

public record EchoResponse(
    String message,
    Instant timestamp
) {
}

