/**
 * Copyright (C) 2015 The Gravitee team (http://gravitee.io)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.suncoast.gravitee.extension.policy;

import io.gravitee.gateway.api.Request;
import io.gravitee.gateway.api.Response;
import io.gravitee.policy.api.PolicyChain;
import io.gravitee.policy.api.annotations.OnRequest;
import io.gravitee.policy.api.annotations.OnResponse;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.SpanContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("unused")
public class TraceContextPolicy {

    private static final Logger LOGGER = LoggerFactory.getLogger(TraceContextPolicy.class);

    /**
     * The associated configuration to this TraceContext Policy
     */
    private TraceContextPolicyConfiguration configuration;

    /**
     * Create a new TraceContext Policy instance based on its associated configuration
     *
     * @param configuration the associated configuration to the new TraceContext Policy instance
     */
    public TraceContextPolicy(TraceContextPolicyConfiguration configuration) {
        this.configuration = configuration;
    }

    @OnRequest
    public void onRequest(Request request, Response response, PolicyChain policyChain) {
        Span span = Span.current();
        SpanContext spanContext = span.getSpanContext();
        if (spanContext.isValid()) {
            String traceId = spanContext.getTraceId();
            String spanId = spanContext.getSpanId();
            request.headers().set("x-trace-id", traceId);
            request.headers().set("x-span-id", spanId);
            LOGGER.info("trace-context-policy trace_id={} span_id={}", traceId, spanId);
        } else {
            LOGGER.warn("trace-context-policy span_context=invalid");
        }

        // Finally continue chaining
        policyChain.doNext(request, response);
    }

    @OnResponse
    public void onResponse(Request request, Response response, PolicyChain policyChain) {
        policyChain.doNext(request, response);
    }

}
