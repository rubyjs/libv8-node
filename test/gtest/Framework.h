#pragma once

#include <v8.h>
#include <libplatform/libplatform.h>
#include <functional>

struct Framework {
	typedef std::function<void()> basic_main;
	typedef std::function<void(v8::Isolate*)> iso_main;
	typedef std::function<void(v8::Local<v8::Context>&)> ctx_main;

	inline static void run(basic_main main) {
		std::shared_ptr<v8::Platform> platform = v8::platform::NewDefaultPlatform();
		v8::V8::InitializePlatform(platform.get());
		v8::V8::Initialize();
		main();

		v8::V8::Dispose();
		v8::V8::ShutdownPlatform();
	}

	inline static void runWithIsolateRaw(iso_main main) {
		Framework::run([main]() -> void {
			v8::Isolate::CreateParams p;
			p.array_buffer_allocator = v8::ArrayBuffer::Allocator::NewDefaultAllocator();
			v8::Isolate* iso = v8::Isolate::New(p);

			main(iso);

			iso->Dispose();
			delete p.array_buffer_allocator;
		});
	}

	inline static void runWithIsolate(iso_main main) {
		Framework::runWithIsolateRaw([main](v8::Isolate* iso) -> void {
			v8::Locker lock { iso };
			v8::Isolate::Scope iScope { iso };
			v8::HandleScope hScope { iso };

			main(iso);
		});
	}

	inline static void runWithContext(ctx_main main) {
		Framework::runWithIsolate([main](v8::Isolate* iso) -> void {
			v8::Local<v8::Context> ctx = v8::Context::New(iso);
			v8::Context::Scope cScope { ctx };

			main(ctx);
		});
	}
};