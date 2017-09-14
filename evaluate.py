import numpy as np
import sys

def checkAssignment(X, ammo):
    ''' Checks whether current assignment is valid or not '''
    if not (4,5) == X.shape:
        print 'Wrong shape for X'
        return False
    X_usage = np.sum(X, axis = 1)
    for i,a_count in enumerate(ammo):
        if X_usage[i] > a_count:
            print 'Ammo overusage for cm type',i
            return False
    return True


def findMostEffective(ammo_remain, er):
    ''' From remaining ammo, return the idx of most effective cm '''
    er_list = [er[i] for i,ammo in enumerate(ammo_remain) if ammo > 0]
    er = list(er)
    idx = er.index(max(er_list))
    return idx


def calculateFutureSurvival(ammo_remain, mmat, ship_values, future_missile_count):
    ''' Unknown missile types and targeting.
        Assumes uniform distribution for those '''

    # Effectiveness ratio
    temp = np.delete(mmat, 1, axis = 1)   # delete one of two hungry missiles for fair average
    er = np.mean(temp, axis = 1)

    num_ships = len(ship_values)
    p_target = np.ones([num_ships,future_missile_count]) / future_missile_count
    mmat_avg = np.transpose(np.tile(er,[future_missile_count,1]))
    X = np.zeros([4,future_missile_count])

    # Greedy assignment
    m = 0
    while sum(ammo_remain) > 0:
        # Find highest effective missile
        idx = findMostEffective(ammo_remain, er)
        # Assign
        X[idx,m] = X[idx,m] + 1
        # Reduce
        ammo_remain[idx] = ammo_remain[idx] - 1
        # Step missile
        if m < 2:
            m = m + 1
        else:
            m = 0

    _, p_survivals = objective(X, mmat_avg, p_target, ship_values)
    return p_survivals




def objective(X, mmat, p_target, ship_values):
    ''' Calculates the objective metric (total weighted survival score)
    for the missile defense scenario

    INPUTS:
    X[d,m] = number of countermeasure d assigned to missile m
    mmat[d,m] = prob. that d neutralizes m
    p_target[a,m] = prob. that ship a is being targeted by m
    ship_values[a] = value of ship a

    OUTPUTS:
    f = total weighted survival score
    p_survivals[a] = unweighted prob. of survivals of assets

    '''

    num_cm_types, num_missiles = mmat.shape

    # Compute objective f
    f = 0.0
    p_survivals = np.zeros(len(ship_values))
    for a in range(len(ship_values)):
        survival_a = 1.0
        for m in range(num_missiles):
            pmiss = 1.0
            for d in range(num_cm_types):
                # Prob that missile m gets through
                pmiss = pmiss * np.power(1 - mmat[d,m], X[d,m])
            # Prob. that asset a survives
            survival_a = survival_a * (1 - p_target[a,m] * pmiss)

        # Total weighted survivability over all assets
        f = f + ship_values[a] * survival_a
        p_survivals[a] = survival_a

    return f, p_survivals



###############################################

if __name__ == "__main__":
    ammo = np.array([5, 3, 3, 6])
    mmat = 0.01* np.array([[40, 60, 60, 30, 0], 
                    [80, 70, 70, 0, 0],
                    [0, 60, 60, 80, 0],
                    [70, 70, 70, 70, 30]])
    p_target = np.array([[1, 1, 0, 0, 1.0/3],
                        [0, 0, 0, 1, 1.0/3],
                        [0, 0, 1, 0, 1.0/3]])
    ship_values = np.array([100, 80, 60]);
    ship_values = 100.0 * ship_values / sum(ship_values);
    X = np.array([[0, 1, 2, 2, 0],
                [2, 1, 0, 0, 0],
                [0, 0, 1, 2, 0],
                [0, 0, 0, 3, 3]])

    if not checkAssignment(X, ammo):
        print 'Current assignment invalid - Exiting'
        sys.exit()

    # Immediate threat calculation
    f, p_immediate = objective(X, mmat, p_target, ship_values)
    print 'p_immediate=',p_immediate

    # Future thread calculation
    future_missile_count = 3
    ammo_remain = ammo - np.sum(X, axis = 1)
    print 'ammo_remain=',ammo_remain
    p_future = calculateFutureSurvival(ammo_remain, mmat, ship_values, future_missile_count)
    print 'p_future=',p_future
    p_overall = p_immediate * p_future
    print 'p_overall=',p_overall
    f = np.dot(ship_values, p_overall)
    print 'final score=',f

