---
title: When to declare methods final
tags: [php, oop, best practices]
summary: So, you already have all your classes final, yeah. But you still use abstract classes, don't you?
tweet: 849249053623889922
---

**TL;DR** Every methods in abstract classes should be final.

I am stupid and I want to understand each and every functionality of a piece of
code in one screen.

Every time I see a class extending another class I get confused:

1. what do this class use of parent class?
1. how much parent behaviour is overridden and how much is genuine?
1. [all other well-known composition-over-inheritance debate]

I am bored to be confused, so after reading [Ocramius] article "[When to declare classes final]"
I ended up writing a custom [PHP-CS-Fixer] fixer that puts `final` keyword
on every non-abstract class - [FinalInternalClassFixer] (except for
[Doctrine Entities] that relay on inheritance for proxying, grrrrr!).

Of course this does not delete `abstract` classes, but at least I gained that:

1. if I see a typehint against an `interface`, I know that the variable typehinted
can be anything (of that interface)
1. if I see a typehint against an `abstract` class, I know that the variable
typehinted may have multiple behaviours (withing the abstract class)
1. if I see a typehint against a real `class`, I know that the variable
typehinted have exactly the class (and its parents) behaviour: no other class
involved
1. Inheritance may happen only with abstract classes: trivial, but important

Still, a typehint on abstract classes exposes an undefined behaviour until you
read every implementation class along with the abstract one.

## Inheritance is unecessary, but if you use it, make it final

Good interface abstraction and composition are enough for every scenario, but
may be verbose.

The only use case I find inheritance *acceptable* is to enforce a part of a
behaviour that would be too verbose to write otherwise.

[Template method pattern] is the way to adhere to an interface specifying only
a part of the full behaviour, letting a subclass the rest of it.

```php
interface Employee
{
    public function work();
    public function relax();
}

final class Secretary implements Employee
{
    public function work()
    {
        echo "I'm switching on the PC";
    }

    public function relax()
    {
        echo "Having a coffee";
    }
}

abstract class Operative implements Employee
{
    final public function work()
    {
        // Here we are: half behaviour enforced due to final keyword
        echo "Protective clothes worn";

        // The other half delegated to subclass due to internal interface
        $this->getHandsDirty();
    }

    abstract protected function getHandsDirty();
}

final class Lumberjack extends Operative
{
    protected function getHandsDirty()
    {
        echo "Got the chainsaw";
    }

    public function relax()
    {
        echo "Sunbathing";
    }
}
```

A Secretary doesn't need protective clothes, while an Operative must wear them.

In respect of a scenario that I would consider ideal, the example shows some
flaws:

1. `Employee` interface hides a security-related behaviour (wearing or
not the protective clothes) that is still hidden
1. creates a new hidden, although internal, API (`getHandsDirty`)

**But** at least all the intentions behind `Operative` abstract class is entirely
in its code and can't be overwritten.

`Lumberjack` will always expose a behaviour that is the result of two classes,
which is bad, **but** al least the two classes have strictly separated and
distinguishable behaviours, which is good.

If you are going to move from an inheritance nightmare to a composition/clear-API
heaven, the first step for sure is to segregate responsabilities between parents
and children.

I wrote another fixer for this purpose, [FinalAbstractPublicFixer] (work *in
fieri*), to ensure no developer in the team can fall again in that bad design.

[Ocramius]: https://twitter.com/Ocramius
[When to declare classes final]: https://ocramius.github.io/blog/when-to-declare-classes-final/
[PHP-CS-Fixer]: https://github.com/FriendsOfPHP/PHP-CS-Fixer
[FinalInternalClassFixer]: https://github.com/Slamdunk/php-cs-fixer-extensions/blob/v1.0.1/lib/FinalInternalClassFixer.php
[Doctrine Entities]: http://docs.doctrine-project.org/projects/doctrine-orm/en/latest/reference/architecture.html#entities
[Template method pattern]: https://en.wikipedia.org/wiki/Template_method_pattern
[FinalAbstractPublicFixer]: https://github.com/Slamdunk/php-cs-fixer-extensions/blob/v1.0.1/lib/FinalAbstractPublicFixer.php
