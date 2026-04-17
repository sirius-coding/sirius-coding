package com.sirius.web.toolkit.error;

import org.springframework.http.HttpStatus;

public enum ErrorCode {
    INVALID_REQUEST(400, "invalid request", HttpStatus.BAD_REQUEST),
    INTERNAL_ERROR(500, "internal error", HttpStatus.INTERNAL_SERVER_ERROR);

    private final int code;
    private final String defaultMessage;
    private final HttpStatus httpStatus;

    ErrorCode(int code, String defaultMessage, HttpStatus httpStatus) {
        this.code = code;
        this.defaultMessage = defaultMessage;
        this.httpStatus = httpStatus;
    }

    public int code() {
        return code;
    }

    public String defaultMessage() {
        return defaultMessage;
    }

    public HttpStatus httpStatus() {
        return httpStatus;
    }
}

