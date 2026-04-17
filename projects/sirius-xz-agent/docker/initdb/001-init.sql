create extension if not exists vector;

create table if not exists knowledge_chunk (
    id bigserial primary key,
    document_id varchar(128) not null,
    document_title varchar(256) not null,
    chunk_index integer not null,
    chunk_text text not null,
    tags text[] not null,
    embedding vector(8) not null,
    created_at timestamp not null default now(),
    unique (document_id, chunk_index)
);
