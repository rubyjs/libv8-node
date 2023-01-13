#include <gtest/gtest.h>

#include <v8.h>
#include <libplatform/libplatform.h>

#include "Framework.h"

// Demonstrate some basic assertions.
TEST(FRLocaleTest, LocaleTests) {
  Framework::runWithContext([](v8::Local<v8::Context>& ctx) -> void {
    v8::Local<v8::Script> script = v8::Script::Compile(ctx, v8::String::NewFromUtf8Literal(ctx->GetIsolate(), "new Date('April 28 2021').toLocaleDateString('fr-FR');")).ToLocalChecked();
    v8::Local<v8::Value> result = script->Run(ctx).ToLocalChecked();
    v8::Local<v8::String> resultStr = result->ToString(ctx).ToLocalChecked();
    v8::String::Utf8Value resultUTF8(ctx->GetIsolate(), resultStr);

    EXPECT_STREQ(*resultUTF8, "28/04/2021");
  });
}
