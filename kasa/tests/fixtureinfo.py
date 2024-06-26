import glob
import json
import os
from pathlib import Path
from typing import Dict, List, NamedTuple, Optional, Set


class FixtureInfo(NamedTuple):
    name: str
    protocol: str
    data: Dict


FixtureInfo.__hash__ = lambda x: hash((x.name, x.protocol))  # type: ignore[attr-defined, method-assign]
FixtureInfo.__eq__ = lambda x, y: hash(x) == hash(y)  # type: ignore[method-assign]


SUPPORTED_IOT_DEVICES = [
    (device, "IOT")
    for device in glob.glob(
        os.path.dirname(os.path.abspath(__file__)) + "/fixtures/*.json"
    )
]

SUPPORTED_SMART_DEVICES = [
    (device, "SMART")
    for device in glob.glob(
        os.path.dirname(os.path.abspath(__file__)) + "/fixtures/smart/*.json"
    )
]


SUPPORTED_DEVICES = SUPPORTED_IOT_DEVICES + SUPPORTED_SMART_DEVICES


def idgenerator(paramtuple: FixtureInfo):
    try:
        return paramtuple.name + (
            "" if paramtuple.protocol == "IOT" else "-" + paramtuple.protocol
        )
    except:  # TODO: HACK as idgenerator is now used by default  # noqa: E722
        return None


def get_fixture_info() -> List[FixtureInfo]:
    """Return raw discovery file contents as JSON. Used for discovery tests."""
    fixture_data = []
    for file, protocol in SUPPORTED_DEVICES:
        p = Path(file)
        folder = Path(__file__).parent / "fixtures"
        if protocol == "SMART":
            folder = folder / "smart"
        p = folder / file

        with open(p) as f:
            data = json.load(f)

        fixture_name = p.name
        fixture_data.append(
            FixtureInfo(data=data, protocol=protocol, name=fixture_name)
        )
    return fixture_data


FIXTURE_DATA: List[FixtureInfo] = get_fixture_info()


def filter_fixtures(
    desc,
    *,
    data_root_filter: Optional[str] = None,
    protocol_filter: Optional[Set[str]] = None,
    model_filter: Optional[Set[str]] = None,
    component_filter: Optional[str] = None,
):
    """Filter the fixtures based on supplied parameters.

    data_root_filter: return fixtures containing the supplied top
        level key, i.e. discovery_result
    protocol_filter: set of protocols to match, IOT or SMART
    model_filter: set of device models to match
    component_filter: filter SMART fixtures that have the provided
    component in component_nego details.
    """

    def _model_match(fixture_data: FixtureInfo, model_filter):
        file_model_region = fixture_data.name.split("_")[0]
        file_model = file_model_region.split("(")[0]
        return file_model in model_filter

    def _component_match(fixture_data: FixtureInfo, component_filter):
        if (component_nego := fixture_data.data.get("component_nego")) is None:
            return False
        components = {
            component["id"]: component["ver_code"]
            for component in component_nego["component_list"]
        }
        return component_filter in components

    filtered = []
    if protocol_filter is None:
        protocol_filter = {"IOT", "SMART"}
    for fixture_data in FIXTURE_DATA:
        if data_root_filter and data_root_filter not in fixture_data.data:
            continue
        if fixture_data.protocol not in protocol_filter:
            continue
        if model_filter is not None and not _model_match(fixture_data, model_filter):
            continue
        if component_filter and not _component_match(fixture_data, component_filter):
            continue

        filtered.append(fixture_data)

    print(f"# {desc}")
    for value in filtered:
        print(f"\t{value.name}")
    return filtered
