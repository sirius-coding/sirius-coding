package com.sirius.xz.agent.persistence;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class PgVectorSqlTest {

    public static void main(String[] args) {
        new PgVectorSqlTest().vectorLiteralFormatsAsPgVectorInput();
    }

    @Test
    void vectorLiteralFormatsAsPgVectorInput() {
        assertThat(PgVectorSql.toVectorLiteral(new float[] {1.0f, 0.25f, 0.0f}))
            .isEqualTo("[1.000000,0.250000,0.000000]");
    }
}
