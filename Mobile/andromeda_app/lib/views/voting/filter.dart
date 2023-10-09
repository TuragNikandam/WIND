import 'package:andromeda_app/models/organization_model.dart';
import 'package:andromeda_app/models/party_model.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/views/utils/texts.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class VotingFilter extends StatefulWidget {
  final List<User> userList;
  final Function(FilterParameters) onFilterChanged;
  final FilterParameters filterParameters;

  const VotingFilter({
    Key? key,
    required this.userList,
    required this.onFilterChanged,
    required this.filterParameters,
  }) : super(key: key);

  @override
  State<VotingFilter> createState() => _VotingFilterState();
}

class _VotingFilterState extends State<VotingFilter> {
  // Filter parameters
  late FilterParameters _filterParameters;

  double _minAge = 16.0; // Default values, will be updated
  double _maxAge = 99.0;

  late Set<Party> _uniqueParties;
  late Set<String> _uniqueReligions;
  late Set<String> _uniqueGenders;

  bool _isAgeFilterExpanded = false;
  bool _isReligionFilterExpanded = false;
  bool _isGenderFilterExpanded = false;
  bool _isPartyFilterExpanded = false;
  bool _isOrganizationFilterExpanded = false;

  @override
  void initState() {
    super.initState();

    _filterParameters = widget.filterParameters;

    // Calculate the minimum and maximum ages based on the user data
    List<int> birthYears = widget.userList
        .where((user) => !user.getIsGuest)
        .map((user) => user.getBirthYear)
        .toList();

    if (birthYears.isNotEmpty) {
      int currentYear = DateTime.now().year;
      _minAge = (currentYear - birthYears.reduce(math.max)).toDouble();
      _maxAge = (currentYear - birthYears.reduce(math.min)).toDouble();
    }

    _filterParameters.currentRangeValues = RangeValues(_minAge, _maxAge);

    _uniqueParties =
        widget.userList.where((user) => !user.getIsGuest).map((user) {
      return PartyManager().getPartyById(user.getSelectedParty);
    }).toSet();

    _uniqueGenders =
        widget.userList.where((user) => !user.getIsGuest).map((user) {
      // Replace 'someGender' with the condition you want to check
      return GenderText.getTexts()
          .firstWhere((element) => element == user.getGender);
    }).toSet();

    _uniqueReligions =
        widget.userList.where((user) => !user.getIsGuest).map((user) {
      // Replace 'someGender' with the condition you want to check
      return ReligionText.getTexts()
          .firstWhere((element) => element == user.getReligion);
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter dialogSetState) {
                  return AlertDialog(
                    title: const Text('Filteroptionen'),
                    content: Scrollbar(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildGuestFilter(dialogSetState),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Divider(
                                      color: Colors.black,
                                      height: 1,
                                      thickness: 0.5),
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: const Text("Oder"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildAgeRangeFilter(dialogSetState),
                              const SizedBox(height: 10),
                              _buildGenderFilter(dialogSetState),
                              const SizedBox(height: 10),
                              _buildReligionFilter(dialogSetState),
                              const SizedBox(height: 10),
                              _buildPartyFilter(dialogSetState),
                              const SizedBox(height: 10),
                              _buildOrganizationFilter(dialogSetState)
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          dialogSetState(() {
                            _resetFilter();
                            _applyFilter();
                          });
                          Navigator.of(context).pop(
                              true); // true indicates that the filter should be reset
                        },
                        child: const Text('Zurücksetzen'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(
                              false); // false indicates that the filter should be applied
                          _applyFilter();
                        },
                        child: const Text('Filtern'),
                      ),
                    ],
                  );
                },
              );
            },
          ).then((resetFilter) {
            if (resetFilter != null) {
              setState(() {
                if (resetFilter) {
                  _resetFilter();
                }
              });
            }
          });
        },
      ),
    );
  }

  void _resetFilter() {
    _filterParameters = FilterParameters.defaultParameters();
    _filterParameters.currentRangeValues = RangeValues(_minAge, _maxAge);
  }

  void _applyFilter() {
    widget.onFilterChanged(_filterParameters);
  }

  Widget _buildGuestFilter(StateSetter dialogSetState) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.fromLTRB(
        5,
        0,
        0,
        0,
      ),
      title: const Text("Gäste berücksichtigen?",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          )),
      value: _filterParameters.includeGuests,
      onChanged: (bool value) {
        dialogSetState(() {
          _filterParameters.includeGuests = value;
          if (value) {
            _resetFilter();
          }
        });
      },
    );
  }

  Widget _buildPartyFilter(StateSetter dialogSetState) {
    return GestureDetector(
      onTap: () {
        dialogSetState(() {
          _isPartyFilterExpanded = !_isPartyFilterExpanded;
        });
      },
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.fromLTRB(
          5,
          0,
          0,
          0,
        ),
        expansionCallback: (int index, bool isExpanded) {
          dialogSetState(() {
            _isPartyFilterExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                contentPadding: EdgeInsets.fromLTRB(
                  5,
                  0,
                  0,
                  0,
                ),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Parteipräferenz',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            isExpanded: _isPartyFilterExpanded,
            body: _buildPartyFilterContent(dialogSetState),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyFilterContent(StateSetter dialogSetState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _filterParameters.selectedParty,
                  hint: const Text("Partei auswählen"),
                  onChanged: (String? newValue) {
                    dialogSetState(() {
                      _filterParameters.selectedParty = newValue;
                      if (newValue != null) {
                        _filterParameters.includeGuests = false;
                      }
                    });
                  },
                  items: _uniqueParties
                      .map<DropdownMenuItem<String>>((Party party) {
                    return DropdownMenuItem<String>(
                      value: party.getId,
                      child: Text(party.getName),
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  dialogSetState(() {
                    _filterParameters.selectedParty = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeFilter(StateSetter dialogSetState) {
    return GestureDetector(
      onTap: () {
        dialogSetState(() {
          _isAgeFilterExpanded = !_isAgeFilterExpanded;
        });
      },
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.fromLTRB(
          5,
          0,
          0,
          0,
        ),
        expansionCallback: (int index, bool isExpanded) {
          dialogSetState(() {
            _isAgeFilterExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                  contentPadding: EdgeInsets.fromLTRB(
                    5,
                    0,
                    0,
                    0,
                  ),
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Altersbereich',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ));
            },
            isExpanded: _isAgeFilterExpanded,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: _buildAgeRangeFilterContent(dialogSetState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeFilterContent(StateSetter dialogSetState) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Row(
          children: [
            Text(
              _minAge.round().toString(),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.orange,
                  inactiveTrackColor: Colors.orange.withOpacity(0.3),
                  thumbColor: Colors.orangeAccent,
                  overlayColor: Colors.orange.withOpacity(0.2),
                  valueIndicatorColor: Colors.orange,
                  valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: RangeSlider(
                  values: _filterParameters.currentRangeValues,
                  min: _minAge,
                  max: _maxAge,
                  divisions: (_maxAge - _minAge).toInt(),
                  labels: RangeLabels(
                    _filterParameters.currentRangeValues.start
                        .round()
                        .toString(),
                    _filterParameters.currentRangeValues.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    dialogSetState(() {
                      _filterParameters.currentRangeValues = values;
                      _filterParameters.includeGuests = false;
                    });
                  },
                ),
              ),
            ),
            Text(
              _maxAge.round().toString(),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                dialogSetState(() {
                  _filterParameters.currentRangeValues =
                      RangeValues(_minAge, _maxAge);
                });
              },
            ),
          ],
        ));
  }

  Widget _buildReligionFilter(StateSetter dialogSetState) {
    return GestureDetector(
      onTap: () {
        dialogSetState(() {
          _isReligionFilterExpanded = !_isReligionFilterExpanded;
        });
      },
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.fromLTRB(
          5,
          0,
          0,
          0,
        ),
        expansionCallback: (int index, bool isExpanded) {
          dialogSetState(() {
            _isReligionFilterExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                contentPadding: EdgeInsets.fromLTRB(
                  5,
                  0,
                  0,
                  0,
                ),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Religion',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            isExpanded: _isReligionFilterExpanded,
            body: _buildReligionFilterContent(dialogSetState),
          ),
        ],
      ),
    );
  }

  Widget _buildReligionFilterContent(StateSetter dialogSetState) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _filterParameters.selectedReligion,
                    hint: const Text("Religion auswählen"),
                    onChanged: (String? newValue) {
                      dialogSetState(() {
                        _filterParameters.selectedReligion = newValue;
                        if (newValue != null) {
                          _filterParameters.includeGuests = false;
                        }
                      });
                    },
                    items: ReligionText.getTexts()
                        .where((text) => _uniqueReligions.contains(text))
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    dialogSetState(() {
                      _filterParameters.selectedReligion = null;
                    });
                  },
                ),
              ],
            )
          ],
        ));
  }

  Widget _buildGenderFilter(StateSetter dialogSetState) {
    return GestureDetector(
      onTap: () {
        dialogSetState(() {
          _isGenderFilterExpanded = !_isGenderFilterExpanded;
        });
      },
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        expansionCallback: (int index, bool isExpanded) {
          dialogSetState(() {
            _isGenderFilterExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                contentPadding: EdgeInsets.fromLTRB(
                  5,
                  0,
                  0,
                  0,
                ),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Geschlecht',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            isExpanded: _isGenderFilterExpanded,
            body: _buildGenderFilterContent(dialogSetState),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderFilterContent(StateSetter dialogSetState) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0), // Add padding here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _filterParameters.selectedGender,
                    hint: const Text("Geschlecht auswählen"),
                    onChanged: (String? newValue) {
                      dialogSetState(() {
                        _filterParameters.selectedGender = newValue;
                        if (newValue != null) {
                          _filterParameters.includeGuests = false;
                        }
                      });
                    },
                    items: GenderText.getTexts()
                        .where((text) => _uniqueGenders.contains(text))
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    dialogSetState(() {
                      _filterParameters.selectedGender = null;
                    });
                  },
                ),
              ],
            )
          ],
        ));
  }

  Widget _buildOrganizationFilter(StateSetter dialogSetState) {
    var organizationList = OrganizationManager().getOrganizationList;

    return GestureDetector(
      onTap: () {
        dialogSetState(() {
          _isOrganizationFilterExpanded = !_isOrganizationFilterExpanded;
        });
      },
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        expansionCallback: (int index, bool isExpanded) {
          dialogSetState(() {
            _isOrganizationFilterExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Organisationen',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            isExpanded: _isOrganizationFilterExpanded,
            body: _buildOrganizationFilterContent(
                organizationList, dialogSetState),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationFilterContent(
      List<Organization> organizationList, StateSetter dialogSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...organizationList.map((org) => CheckboxListTile(
              title: Text(org.getShortName),
              value:
                  _filterParameters.selectedOrganizations.contains(org.getId),
              onChanged: (bool? value) {
                dialogSetState(() {
                  if (value == true) {
                    _filterParameters.selectedOrganizations.add(org.getId);
                    _filterParameters.includeGuests = false;
                  } else {
                    _filterParameters.selectedOrganizations.remove(org.getId);
                  }
                });
              },
            ))
      ],
    );
  }
}

class VotingFilterUtility {
  static bool shouldIncludeVote(User user, FilterParameters params) {
    final int currentYear = DateTime.now().year;
    final int userAge = currentYear - user.getBirthYear;

    bool isPartyMatch() {
      return params.selectedParty == null ||
          params.selectedParty == user.getSelectedParty;
    }

    bool isGenderMatch() {
      return params.selectedGender == null ||
          params.selectedGender == user.getGender;
    }

    bool isGuestMatch() {
      return params.includeGuests || !user.getIsGuest;
    }

    bool isAgeMatch() {
      return user.getIsGuest ||
          (userAge >= params.currentRangeValues.start &&
              userAge <= params.currentRangeValues.end);
    }

    bool isOrganizationMatch() {
      return params.selectedOrganizations.isEmpty ||
          params.selectedOrganizations
              .any((org) => user.getSelectedOrganizations.contains(org));
    }

    bool isReligionMatch() {
      return params.selectedReligion == null ||
          params.selectedReligion == user.getReligion;
    }

    return isPartyMatch() &&
        isGenderMatch() &&
        isGuestMatch() &&
        isAgeMatch() &&
        isOrganizationMatch() &&
        isReligionMatch();
  }
}

class FilterParameters {
  String? selectedParty;
  bool includeGuests;
  RangeValues currentRangeValues;
  List<String> selectedOrganizations;
  String? selectedGender;
  String? selectedReligion;

  FilterParameters({
    this.selectedParty,
    this.includeGuests = true,
    this.currentRangeValues = const RangeValues(16, 99),
    this.selectedOrganizations = const [],
    this.selectedGender,
    this.selectedReligion,
  });

  factory FilterParameters.defaultParameters() {
    return FilterParameters(
      selectedParty: null,
      includeGuests: true,
      currentRangeValues: const RangeValues(16, 99),
      selectedOrganizations: const [],
      selectedGender: null,
      selectedReligion: null,
    );
  }
}
