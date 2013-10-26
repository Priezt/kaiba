class Duel
	def add_timing_hook(hook_proc)
		@timing_hooks ||= []
		@timing_hooks << hook_proc
	end

	def add_choose_hook(hook_proc)
		@choose_hooks ||= []
		@choose_hooks << hook_proc
	end

	def timing_hooks
		@timing_hooks ||= []
	end

	def choose_hooks
		@choose_hooks ||= []
	end
end
