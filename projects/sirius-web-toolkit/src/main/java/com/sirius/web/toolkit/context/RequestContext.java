package com.sirius.web.toolkit.context;

import java.util.UUID;

public final class RequestContext {

    private static final ThreadLocal<String> REQUEST_ID = new ThreadLocal<>();

    private RequestContext() {
    }

    public static void setRequestId(String requestId) {
        REQUEST_ID.set(requestId);
    }

    public static String currentRequestId() {
        String requestId = REQUEST_ID.get();
        return requestId == null || requestId.isBlank() ? "unknown" : requestId;
    }

    public static String resolveOrCreate(String requestId) {
        if (requestId == null || requestId.isBlank()) {
            return UUID.randomUUID().toString();
        }
        return requestId;
    }

    public static void clear() {
        REQUEST_ID.remove();
    }
}

