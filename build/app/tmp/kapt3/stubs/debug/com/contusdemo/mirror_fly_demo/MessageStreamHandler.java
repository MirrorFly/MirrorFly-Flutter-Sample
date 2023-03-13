package com.contusdemo.mirror_fly_demo;

import java.lang.System;

@kotlin.Metadata(mv = {1, 6, 0}, k = 1, d1 = {"\u0000*\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\u0000\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0000\u0018\u00002\u00020\u00012\u00020\u0002B\u0005\u00a2\u0006\u0002\u0010\u0003J\u0012\u0010\u0006\u001a\u00020\u00072\b\u0010\b\u001a\u0004\u0018\u00010\tH\u0016J\u001c\u0010\n\u001a\u00020\u00072\b\u0010\b\u001a\u0004\u0018\u00010\t2\b\u0010\u000b\u001a\u0004\u0018\u00010\u0005H\u0016J\u0010\u0010\f\u001a\u00020\u00072\u0006\u0010\r\u001a\u00020\u000eH\u0016R\u0010\u0010\u0004\u001a\u0004\u0018\u00010\u0005X\u0082\u000e\u00a2\u0006\u0002\n\u0000\u00a8\u0006\u000f"}, d2 = {"Lcom/contusdemo/mirror_fly_demo/MessageStreamHandler;", "Lcom/contusflysdk/activities/FlyBaseActivity;", "Lio/flutter/plugin/common/EventChannel$StreamHandler;", "()V", "chatEventSink", "Lio/flutter/plugin/common/EventChannel$EventSink;", "onCancel", "", "arguments", "", "onListen", "events", "onMessageReceived", "message", "Lcom/contusflysdk/api/models/ChatMessage;", "app_debug"})
public final class MessageStreamHandler extends com.contusflysdk.activities.FlyBaseActivity implements io.flutter.plugin.common.EventChannel.StreamHandler {
    private io.flutter.plugin.common.EventChannel.EventSink chatEventSink;
    
    public MessageStreamHandler() {
        super();
    }
    
    @java.lang.Override()
    public void onListen(@org.jetbrains.annotations.Nullable()
    java.lang.Object arguments, @org.jetbrains.annotations.Nullable()
    io.flutter.plugin.common.EventChannel.EventSink events) {
    }
    
    @java.lang.Override()
    public void onCancel(@org.jetbrains.annotations.Nullable()
    java.lang.Object arguments) {
    }
    
    @java.lang.Override()
    public void onMessageReceived(@org.jetbrains.annotations.NotNull()
    com.contusflysdk.api.models.ChatMessage message) {
    }
}