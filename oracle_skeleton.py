import json
from typing import Dict, Any, Tuple

# Placeholder imports – in a real setup you'd use web3.py to talk to the chain.
# from web3 import Web3

def validate_mission(wallet: str, mission_type: int, payload: Dict[str, Any]) -> Tuple[bool, int]:
    """Route to mission-type-specific validators.

    For now this is just a stub. In your real code, you'd import validators like:
        - validate_data_task_mission
        - validate_uplift_mission
        - validate_impact_investor_mission
        - etc.
    and call them here based on mission_type.
    """
    # Example stub: always invalid
    return False, 0


def handle_claim(claim: Dict[str, Any]) -> Dict[str, Any]:
    """High-level oracle entrypoint.

    Expected claim format:
    {
        "wallet": "0x...",
        "missionType": 1,
        "payload": {...}
    }
    """
    wallet = claim.get("wallet")
    mission_type = int(claim.get("missionType", -1))
    payload = claim.get("payload") or {}

    if not wallet or mission_type < 0:
        return {"ok": False, "error": "Invalid claim format"}

    valid, reward_wei = validate_mission(wallet, mission_type, payload)
    if not valid or reward_wei <= 0:
        return {"ok": False, "valid": False, "reward_wei": 0}

    # In a real implementation:
    #  1. Build a unique missionId (e.g., keccak(wallet, missionType, payload hash)).
    #  2. Send a transaction calling AngelCoin.mintForMission(to, amount, missionType, missionId).
    #  3. Optionally, call ImpactScoreRegistry.addImpactScore(wallet, points).

    return {
        "ok": True,
        "valid": True,
        "reward_wei": reward_wei,
        "note": "In a real oracle, this is where you'd submit the mint tx."
    }


if __name__ == "__main__":
    # Simple manual test
    sample_claim = {
        "wallet": " 0x2177b5c7712d3ec53a2f2d47107e2611169c1a45",
        "missionType": 1,
        "payload": {"taskId": "example_task", "answer": "a"}
    }
    print(json.dumps(handle_claim(sample_claim), indent=2))
