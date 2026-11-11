import math
import unittest

from rig_triceratops import CYCLE, RUN_STANCE, RUN_STRIDE, STANCE, STRIDE, foot_offset


class GaitTest(unittest.TestCase):
    def test_foot_velocity_is_continuous_at_lift_and_landing(self):
        step = 0.00001
        for stride, stance in [(STRIDE, STANCE), (RUN_STRIDE, RUN_STANCE)]:
            for phase in [stance, 1.0]:
                before, at, after = [foot_offset(p, stride, stance) for p in [phase - step, phase, phase + step]]
                incoming = [(b - a) / (step * CYCLE) for a, b in zip(before, at)]
                outgoing = [(b - a) / (step * CYCLE) for a, b in zip(at, after)]
                self.assertLess(math.dist(incoming, outgoing), 0.005, f"Foot snaps at phase {phase}")

    def test_stance_keeps_the_foot_planted(self):
        for stride, stance in [(STRIDE, STANCE), (RUN_STRIDE, RUN_STANCE)]:
            for i in range(65):
                phase = stance * i / 65
                height, z = foot_offset(phase, stride, stance)
                self.assertEqual(height, 0)
                self.assertAlmostEqual(z - phase * stride / stance, -stride / 2)


if __name__ == "__main__":
    unittest.main()
