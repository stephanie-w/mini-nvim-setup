#!/usr/bin/env python3
"""
Interactive Sandbox Generator & Isolated Git Repository Manager.

Creates a 100% self-contained Git repository in sandbox/playground/ so you can test:
1. Real Git hunks (], [, ghgh, gHgh, <leader>td) against a committed baseline.
2. Git status, interactive commits, branch logs, commit graphs, stashes, and Delta.
3. Native LSP (Ruff & ty) diagnostics, auto-fixes, hovers, signatures, and rename.
4. Keeping the main config repository 100% clean and untouched.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
from pathlib import Path

SANDBOX_DIR = Path(__file__).resolve().parent
PLAYGROUND_DIR = SANDBOX_DIR / "playground"

SERVICE_BASE_CONTENT = '''"""
Sandbox Service Module for Neovim Testing.

This module is intentionally structured for testing:
1. Native LSP (Ruff & ty) diagnostics, hovers, signatures, code actions, and rename.
2. Git workflows (gutter diffs, hunk staging, line staging, inline diffs, commits).
3. Formatting on save and trailing whitespace trimming.
"""

from __future__ import annotations

import math  # Ruff: F401 (unused import - press <leader>ca to autofix)
import sys   # Ruff: F401 (unused import - press <leader>ca to autofix)
from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional


@dataclass
class OrderItem:
    """Represents an individual item within an order."""

    sku: str
    quantity: int
    unit_price: float

    def get_subtotal(self) -> float:
        """Calculate line item total price."""
        return self.quantity * self.unit_price


class PaymentGateway:
    """Simulated payment gateway integration."""

    def __init__(self, api_key: str, sandbox_mode: bool = True) -> None:
        self.api_key = api_key
        self.sandbox_mode = sandbox_mode

    def authorize(self, amount: float, currency: str = "USD") -> dict[str, str]:
        """Authorize a charge against the payment provider.

        :param amount: Total amount to authorize.
        :param currency: Three-letter ISO currency code.
        :return: Transaction status dictionary.
        """
        if amount <= 0:
            raise ValueError("Authorization amount must be strictly positive")
        return {
            "status": "APPROVED",
            "currency": currency,
            "auth_code": "AUTH-9988-OK",
        }


class OrderProcessor:
    """Core processor for handling customer orders and payments."""

    def __init__(self, gateway: PaymentGateway) -> None:
        self.gateway = gateway
        self.orders: dict[str, list[OrderItem]] = {}

    def calculate_discount(self, total: float, rate: float) -> float:
        """Compute the discounted price based on a percentage rate."""
        return total * (1.0 - rate)

    def process_order(
        self,
        order_id: str,
        items: list[OrderItem],
        discount_rate: float = 0.0,
    ) -> dict[str, object]:
        """Validate order items, compute totals with discount, and charge gateway.

        Press <C-k> while cursor is inside arguments to view signature.
        Press K on method name to view docstring.
        """
        if not items:
            raise ValueError("Order must contain at least one item")

        self.orders[order_id] = items
        subtotal = sum(item.get_subtotal() for item in items)
        final_total = self.calculate_discount(subtotal, discount_rate)

        charge_result = self.gateway.authorize(final_total)

        return {
            "order_id": order_id,
            "items_count": len(items),
            "subtotal": subtotal,
            "total_charged": final_total,
            "payment": charge_result,
        }


def run_demo() -> None:
    """Run a quick local demonstration."""
    gw = PaymentGateway(api_key="demo-test-token", sandbox_mode=True)
    processor = OrderProcessor(gateway=gw)

    items = [
        OrderItem(sku="PROD-A100", quantity=2, unit_price=49.99),
        OrderItem(sku="PROD-B200", quantity=1, unit_price=120.00),
    ]

    result = processor.process_order(
        order_id="ORD-2026-001",
        items=items,
        discount_rate=0.10,
    )
    print("Order Processed Successfully:", result)


if __name__ == "__main__":
    run_demo()
'''

CLIENT_CONTENT = '''"""
Sandbox Client Script.

Use this file to test:
1. Go-to-definition ('gd') on imported classes and functions.
2. LSP References ('<leader>pr') across multiple files.
3. LSP Smart Rename ('<leader>rn').
4. Python REPL line/selection execution ('<leader>rr').
"""

from __future__ import annotations

from service import OrderItem, OrderProcessor, PaymentGateway


def execute_client_flow() -> None:
    """Execute customer orders via the OrderProcessor service."""
    # Press 'gd' over PaymentGateway or OrderProcessor to jump to service.py
    gateway = PaymentGateway(api_key="client-secret-key-123", sandbox_mode=True)
    processor = OrderProcessor(gateway=gateway)

    cart = [
        OrderItem(sku="WIDGET-01", quantity=3, unit_price=15.50),
        OrderItem(sku="GADGET-02", quantity=1, unit_price=89.00),
    ]

    # Test signature help: Place cursor inside parentheses and press <C-k>
    # Test references: Place cursor on process_order and press <leader>pr
    response = processor.process_order(
        order_id="CLIENT-TX-8821",
        items=cart,
        discount_rate=0.05,
    )

    print("Client Transaction Complete:")
    print("  Order ID:", response["order_id"])
    print("  Total Paid:", response["total_charged"])


if __name__ == "__main__":
    execute_client_flow()
'''

SERVICE_MODIFIED_CONTENT = '''"""
Sandbox Service Module for Neovim Testing.

This module is intentionally structured for testing:
1. Native LSP (Ruff & ty) diagnostics, hovers, signatures, code actions, and rename.
2. Git workflows (gutter diffs, hunk staging, line staging, inline diffs, commits).
3. Formatting on save and trailing whitespace trimming.
"""

from __future__ import annotations

import os    # UNCOMMITTED HUNK 1: Extra unused import (Ruff F401)
import math  # Ruff: F401 (unused import - press <leader>ca to autofix)
import sys   # Ruff: F401 (unused import - press <leader>ca to autofix)
from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional


@dataclass
class OrderItem:
    """Represents an individual item within an order."""

    sku: str
    quantity: int
    unit_price: float

    def get_subtotal(self) -> float:
        """Calculate line item total price."""
        return self.quantity * self.unit_price


class PaymentGateway:
    """Simulated payment gateway integration."""

    def __init__(self, api_key: str, sandbox_mode: bool = True) -> None:
        self.api_key = api_key
        self.sandbox_mode = sandbox_mode

    def authorize(self, amount: float, currency: str = "USD") -> dict[str, str]:
        """Authorize a charge against the payment provider.

        :param amount: Total amount to authorize.
        :param currency: Three-letter ISO currency code.
        :return: Transaction status dictionary.
        """
        if amount <= 0:
            raise ValueError("Authorization amount must be strictly positive")
        return {
            "status": "APPROVED",
            "currency": currency,
            "auth_code": "AUTH-9988-OK",
            "timestamp": datetime.now().isoformat(),  # UNCOMMITTED HUNK 2: Added timestamp field
        }

    def refund(self, transaction_id: str, amount: float) -> dict[str, str]:
        """UNCOMMITTED HUNK 3: Refund an authorized transaction."""
        return {"status": "REFUNDED", "tx_id": transaction_id, "amount": str(amount)}


class OrderProcessor:
    """Core processor for handling customer orders and payments."""

    def __init__(self, gateway: PaymentGateway) -> None:
        self.gateway = gateway
        self.orders: dict[str, list[OrderItem]] = {}

    def calculate_discount(self, total: float, rate: float) -> float:
        """Compute the discounted price based on a percentage rate."""
        return total * (1.0 - rate)

    def process_order(
        self,
        order_id: str,
        items: list[OrderItem],
        discount_rate: float = 0.0,
    ) -> dict[str, object]:
        """Validate order items, compute totals with discount, and charge gateway.

        Press <C-k> while cursor is inside arguments to view signature.
        Press K on method name to view docstring.
        """
        if not items:
            raise ValueError("Order must contain at least one item")

        self.orders[order_id] = items
        subtotal = sum(item.get_subtotal() for item in items)
        final_total = self.calculate_discount(subtotal, discount_rate)

        charge_result = self.gateway.authorize(final_total)

        return {
            "order_id": order_id,
            "items_count": len(items),
            "subtotal": subtotal,
            "total_charged": final_total,
            "payment": charge_result,
            "processed_at": datetime.now().isoformat(),  # UNCOMMITTED HUNK 4: Processed timestamp
        }


def run_demo() -> None:
    """Run a quick local demonstration."""
    gw = PaymentGateway(api_key="demo-test-token", sandbox_mode=True)
    processor = OrderProcessor(gateway=gw)

    items = [
        OrderItem(sku="PROD-A100", quantity=2, unit_price=49.99),
        OrderItem(sku="PROD-B200", quantity=1, unit_price=120.00),
    ]

    result = processor.process_order(
        order_id="ORD-2026-001",
        items=items,
        discount_rate=0.10,
    )
    print("Order Processed Successfully:", result)


if __name__ == "__main__":
    run_demo()
'''

README_PLAYGROUND = """# Sandbox Playground (Isolated Git & LSP Environment)

This directory is an isolated Git repository initialized for practicing Neovim features safely.
"""


def run_cmd(cmd: list[str], cwd: Path) -> None:
    subprocess.run(
        cmd,
        cwd=cwd,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def setup_playground(clean_only: bool = False) -> None:
    if PLAYGROUND_DIR.exists():
        shutil.rmtree(PLAYGROUND_DIR)

    PLAYGROUND_DIR.mkdir(parents=True, exist_ok=True)

    # 1. Initialize isolated git repo
    run_cmd(["git", "init", "-b", "main"], PLAYGROUND_DIR)
    run_cmd(["git", "config", "user.name", "Sandbox Developer"], PLAYGROUND_DIR)
    run_cmd(["git", "config", "user.email", "dev@sandbox.local"], PLAYGROUND_DIR)

    # 2. Commit initial files (Base commit 1)
    (PLAYGROUND_DIR / "service.py").write_text(SERVICE_BASE_CONTENT)
    (PLAYGROUND_DIR / "client.py").write_text(CLIENT_CONTENT)
    (PLAYGROUND_DIR / "README.md").write_text(README_PLAYGROUND)
    run_cmd(["git", "add", "."], PLAYGROUND_DIR)
    run_cmd(["git", "commit", "-m", "feat: initial commit of payment service and client"], PLAYGROUND_DIR)

    # 3. Create a commit 2 on main for realistic git log
    (PLAYGROUND_DIR / "notes.txt").write_text("API v1 integration complete.\n")
    run_cmd(["git", "add", "notes.txt"], PLAYGROUND_DIR)
    run_cmd(["git", "commit", "-m", "docs: add release notes and API specifications"], PLAYGROUND_DIR)

    # 4. Create a demo feature branch and commit
    run_cmd(["git", "checkout", "-b", "feature/async-webhook"], PLAYGROUND_DIR)
    (PLAYGROUND_DIR / "webhook.py").write_text("# Webhook receiver module (WIP)\n")
    run_cmd(["git", "add", "webhook.py"], PLAYGROUND_DIR)
    run_cmd(["git", "commit", "-m", "feat(webhook): scaffold webhook receiver handler"], PLAYGROUND_DIR)

    # 5. Switch back to main branch
    run_cmd(["git", "checkout", "main"], PLAYGROUND_DIR)

    # 6. Create a demo stash
    (PLAYGROUND_DIR / "notes.txt").write_text("Temporary WIP notes on database retry logic\n")
    run_cmd(["git", "stash", "push", "-m", "WIP on database retry logic"], PLAYGROUND_DIR)

    if not clean_only:
        # 7. Introduce 4 distinct uncommitted hunks in service.py
        (PLAYGROUND_DIR / "service.py").write_text(SERVICE_MODIFIED_CONTENT)
        print("✓ Isolated sandbox repository created at sandbox/playground/.git")
        print("✓ Injected 4 live uncommitted Git hunks + mock commits + branch + stash!")
    else:
        print("✓ Isolated sandbox repository created in clean state (no diffs).")

    print("\n👉 Launch Neovim in the isolated playground:")
    print("   ./nv sandbox/playground/service.py")


def main() -> None:
    parser = argparse.ArgumentParser(description="Neovim Isolated Sandbox Setup")
    parser.add_argument("--clean", action="store_true", help="Set up playground without uncommitted diffs")
    args = parser.parse_args()
    setup_playground(clean_only=args.clean)


if __name__ == "__main__":
    main()
