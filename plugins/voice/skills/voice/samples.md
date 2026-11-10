# Samples of his own writing

Excerpts, kept as he wrote them. Match the rhythm, not the topic.

## Opinion post (from "Should you study software engineering?")

> Some version of this comes up every semester. If an agent can write the code,
> why spend five years learning to write it?
>
> It's a fair question. I write less code by hand every month, and the code I
> don't write is often better than what I would have typed. So the short answer
> from me, someone who teaches it and works in it: yes, study it.
>
> ## What got cheap
>
> Writing code got cheap. Not free, but cheap enough that "I know the syntax"
> stopped being worth much.
>
> …
>
> That part is still expensive. The bugs that wake you up at 3 am rarely live in
> the code you just wrote. They live underneath it: a disk that filled up, a
> network that split in two, a pod the scheduler has nowhere to put. An agent is
> a good shovel. You still have to pick the spot, and you have to notice when it
> digs up nonsense.

## Opinion post, the close (from "Slop, taste, and principles")

> Principles matter more with AI, not less. An agent follows the patterns it
> sees. If the codebase has clear seams and a few written rules, it fills in
> parts that already have a shape. If it doesn't, it's fast at making more slop.
> So write them down where the agent will read them, in the repo, next to the
> code.
>
> Slop is the default. Taste is how you see past it. Principles are how you keep
> seeing it when you're not the one typing.

## Technical post (from "Building your own sandboxes")

> The short version: the microVM is the easy part. The hard part is everything
> around it. Who runs the VMM, what it can open, where its packets go, and what
> the guest is allowed to tell you.
>
> …
>
> Why a microVM and not a container? A container shares the host kernel, so
> every syscall is attack surface. A microVM has its own kernel, so an escape
> needs a guest kernel bug and a KVM or VMM bug. But that only holds if the VMM
> itself is locked down. Firecracker's answer is its jailer, and the jailer needs
> root. I wanted neither root nor a weaker bar.
>
> …
>
> - **The VMM is the smallest part.** Most of the code, and nearly all the bugs,
>   are in who runs it, what it can open and where its packets go.
> - **Put the policy outside the guest.** Firewall, kernel and init are decided
>   on the host, where a compromised guest can't argue.

## Recipe (from "Lasagna (my way)")

> Make the ragu the day before if you can. It cuts cleaner and tastes better.
>
> 2. Add the beef and pork, and break them up as they brown. Let the bottom catch
>    a little before you stir: that's flavour.
>
> 4. Wrap it and rest it for 30 minutes at room temperature. This is what lets it
>    roll out without fighting back.
>
> Some families add raisins or a few chopped olives to the meat sauce, or a layer
> of sliced boiled egg. Mine doesn't, but none of them are wrong.

## Casual register, only when asked (from "spite driven development")

> it always starts the same. a competitor ships something mid. a company tells
> you its "not on the roadmap". a coworker says "that cant be done". a friend
> says your idea is dumb. a tool you use every day is just bad
>
> …
>
> spite is fuel, not a plan. the agent keeps going way after you stopped caring,
> thats how you end up with 4000 lines you're scared to open
>
> ship while you're mad. refactor when you're calm, or never
>
> either way you won
