class StatusEffect : Inventory abstract {
    // An item that tracks a status effect.
    // For the sake of avoiding Weird Behavior, it handles inventory changes in a special way,
    // much like LegendItems do.
    double stacks;
    double stackLimit; // optionally cap the number of stacks a StatusEffect can have.
    double stackGiven;
    property StackLimit: stackLimit;
    property StackGiven: stackGiven;
    double timer;
    double timeLimit;
    property Timer: timeLimit;

    bool active; // Is the effect currently running?

    default {
        StatusEffect.StackLimit -1; // less than zero disables stack limits
        StatusEffect.StackGiven 1; // 1 should work for most use-cases.
        StatusEffect.Timer 1.; // Defaults map to 1 stack = 1 second of effect
    }

    override void PostBeginPlay() {
        // Set this effect's stacks to StackGiven.
        // Just in case this is manually set, though...
        if (stacks <= 0) {
            GiveStacks(stackGiven);
        }
    }

    bool TimeUp() {
        return timer <= 0;
    }

    void SetTimer(double time = -1) {
        if(time < 0) {
            timer = timeLimit;
        } else {
            timer = time;
        }
    }

    double GiveStacks(double amt) {
        // Increment stacks and call OnStack.
        self.OnStack(amt);
        active = true;
        SetTimer(); // Starting the timer prevents effects from expiring in the same tick that they start.
        if (stackLimit < 0) {
            stacks += amt;
        } else {
            stacks = min(stacks + amt, stackLimit);
        }
        return stacks;
    }
    
    double TakeStacks(double amt) {
        // Remove stacks.
        // Stacks should not go below zero!
        stacks = max(0,stacks - amt);
        return stacks;
    }

    override bool HandlePickup(Inventory item) {
        if (item.GetClassName() == self.GetClassName()) {
            self.GiveStacks(self.stackGiven*item.amount);
            return true;
        }
        return false;
    }

    override void DoEffect() {
        // If the effect is currently active...
        if (active) {
            // Call OnTick every tick...
            self.OnTick();
            // And then handle timers.
            if(TimeUp()) {
                if (stacks <= 0) {
                    // The effect ended! Call OnEnd.
                    // OnEnd is responsible for setting active to false.
                    self.OnEnd();
                }
                // Call OnTimer whenever time is up.
                // OnTimer is responsible for setting the timer.
                self.OnTimer();
            } else {
                // Call WhileTimer every tick while the timer is ticking.
                self.WhileTimer();
                timer -= 1./35.;
            }
        } 

    }

    virtual void OnStack(int amt) {} 
    // Called whenever this item's stack count increases, once per stack added. 
    // Useful for things like Bleed's secondary timer resetting on stack.

    virtual void OnTick() {}
    // Called every tick. Separate from DoEffect to avoid Super.DoEffect footguns.

    virtual void OnTimer() { 
        if (stacks < timeLimit) {
            SetTimer(stacks);
        } else {
            SetTimer();
        }
        TakeStacks(timeLimit); 
    }
    // Called when the alarm goes off. Typically handles taking old stacks.

    virtual void WhileTimer() {}
    // Called once per tick while the timer is ticking.

    virtual void OnEnd() { active = false; }
    // Call this whenever the effect runs out of stacks. Handles cleaning up the status effect.
}

#include "zscript/core/effects/cc.zs"
#include "zscript/core/effects/dmg.zs"
#include "zscript/core/effects/dot.zs"