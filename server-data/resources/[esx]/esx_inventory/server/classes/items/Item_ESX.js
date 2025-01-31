class Item_ESX extends Item_Abstract {

	constructor(name, extra, amount) {
		super(name, extra, amount);
		this.weight = 0;
		this.saveable = false;

		if (ESXItemDB[this.extra.name] !== undefined) {
			this.weight = (global.ESXItemDB[this.extra.name].weight || 0) / 1000.0;
		}

//		this.actions.push(new Action_ESXUse(this));
	}

	addItem(inventory) {
		var xPlayer = inventory.getXPlayer();
		if (xPlayer == null) {
			return super.addItem(inventory);
		}

		if (this.extra == null) {
			return false;
		}

		xPlayer.addInventoryItem(this.extra.name, this.amount);
		return true;
	}

	removeItem(inventory) {
		var xPlayer = inventory.getXPlayer();
		if (xPlayer == null) {
			return super.removeItem(inventory);
		}

		if (this.extra == null) {
			return false;
		}

                var curitem = xPlayer.getInventoryItem(this.extra.name);
                if (curitem == null) {
                    return false;
                }
                if (curitem.count != null && curitem.count >= this.amount) {
                    xPlayer.removeInventoryItem(this.extra.name, this.amount);
                } else {
                    return false;
                }

                return true;
	}

	get label() {
		return this.extra.label;
	}

	getProp() {
		if (this.extra == null) {
			return 'prop_money_bag_01';
		}

		if (ESXItemDB[this.extra.name] !== undefined && ESXItemDB[this.extra.name].prop !== undefined) {
			return ESXItemDB[this.extra.name].prop;
		}
		return 'prop_money_bag_01';
	}
}

