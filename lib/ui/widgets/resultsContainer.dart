import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/resultTabSelectionCubit.dart';
import 'package:eschool/cubits/resultsCubit.dart';
import 'package:eschool/cubits/resultsOnlineCubit.dart';
import 'package:eschool/cubits/schoolSessionYearsCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';

import 'package:eschool/data/models/result.dart';
import 'package:eschool/data/models/resultOnline.dart';
import 'package:eschool/data/models/sessionYear.dart';
import 'package:eschool/data/models/subject.dart';

import 'package:eschool/ui/widgets/assignmentsSubjectsContainer.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/listItemForExamAndResult.dart';
import 'package:eschool/ui/widgets/listItemForOnlineExamAndOnlineResult.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/svgButton.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';

import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:get/get.dart';

class ResultsContainer extends StatefulWidget {
  final int? childId;
  final List<Subject>? subjects;

  const ResultsContainer({Key? key, this.childId, this.subjects})
      : super(key: key);

  @override
  State<ResultsContainer> createState() => _ResultsContainerState();
}

class _ResultsContainerState extends State<ResultsContainer> {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_resultsScrollListener);

  List<SessionYear> _sessionYears = [];
  SessionYear? _selectedSessionYear;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _fetchSessionYears();
    });
    super.initState();
  }

  void _fetchSessionYears() {
    context.read<SchoolSessionYearsCubit>().fetchSessionYears(
          useParentApi: context.read<AuthCubit>().isParent(),
          childId: widget.childId ?? 0,
        );
  }

  void fetchResults() {
    context.read<ResultsCubit>().fetchResults(
          useParentApi: context.read<AuthCubit>().isParent(),
          childId: widget.childId,
          sessionYearId: _selectedSessionYear?.id,
        );
  }

  void _resultsScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<ResultTabSelectionCubit>().isResultOnline()) {
        if (context.read<ResultsOnlineCubit>().hasMore()) {
          context.read<ResultsOnlineCubit>().fetchMoreResultsOnline(
                useParentApi: context.read<AuthCubit>().isParent(),
                childId: widget.childId ?? 0,
                classSubjectId: context
                    .read<ResultTabSelectionCubit>()
                    .state
                    .resultFilterByClassSubjectId,
                sessionYearId: _selectedSessionYear?.id,
              );
          //to scroll to last in order for users to see the progress
          Future.delayed(const Duration(milliseconds: 10), () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
            );
          });
        }
      } else {
        if (context.read<ResultsCubit>().hasMore()) {
          context.read<ResultsCubit>().fetchMoreResults(
                useParentApi: context.read<AuthCubit>().isParent(),
                childId: widget.childId,
                sessionYearId: _selectedSessionYear?.id,
              );
          //to scroll to last in order for users to see the progress
          Future.delayed(const Duration(milliseconds: 10), () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
            );
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_resultsScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTapFilterButton() {
    if (_sessionYears.isEmpty) return;

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Utils.bottomSheetTopRadius),
          topRight: Radius.circular(Utils.bottomSheetTopRadius),
        ),
      ),
      context: context,
      builder: (_) => _SessionYearFilterSheet(
        sessionYears: _sessionYears,
        selectedSessionYear: _selectedSessionYear,
        onSessionYearSelected: (sessionYear) {
          setState(() {
            _selectedSessionYear = sessionYear;
          });
          Navigator.of(context).pop();
          fetchResults();
          fetchOnlineResults();
        },
      ),
    );
  }

  Widget _buildAppBar(ResultTabSelectionState currentState) {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              context.read<AuthCubit>().isParent()
                  ? const CustomBackButton()
                  : const SizedBox.shrink(),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: boxConstraints.maxWidth * (0.5),
                  child: Text(
                    Utils.getTranslatedLabel(resultsKey),
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: Utils.screenContentHorizontalPadding,
                  ),
                  child: SvgButton(
                    onTap: _onTapFilterButton,
                    svgIconUrl: Utils.getImagePath("filter_icon.svg"),
                  ),
                ),
              ),
              AnimatedAlign(
                curve: Utils.tabBackgroundContainerAnimationCurve,
                duration: Utils.tabBackgroundContainerAnimationDuration,
                alignment: currentState.resultFilterTabTitle == offlineKey
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child:
                    TabBarBackgroundContainer(boxConstraints: boxConstraints),
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerStart,
                isSelected: currentState.resultFilterTabTitle == offlineKey,
                onTap: () {
                  context
                      .read<ResultTabSelectionCubit>()
                      .changeResultFilterTabTitle(offlineKey);
                },
                titleKey: offlineKey,
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerEnd,
                isSelected: currentState.resultFilterTabTitle == onlineKey,
                onTap: () {
                  context
                      .read<ResultTabSelectionCubit>()
                      .changeResultFilterTabTitle(onlineKey);
                },
                titleKey: onlineKey,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultDetailsShimmerLoadingContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.5),
      width: MediaQuery.of(context).size.width * (0.85),
      height: 80.0,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  width: boxConstraints.maxWidth * (0.7),
                ),
              ),
              SizedBox(
                height: boxConstraints.maxHeight * (0.25),
              ),
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  width: boxConstraints.maxWidth * (0.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultDetailsContainer({
    required Result result,
    required int index,
    required int totalResults,
    required bool hasMoreResults,
    required bool hasMoreResultsInProgress,
    required bool fetchMoreResultsFailure,
  }) {
    return Column(
      children: [
        ListItemForExamAndResult(
          index: index,
          examStartingDate: result.examDate,
          examName: result.examName,
          resultGrade: result.grade,
          resultPercentage: result.percentage,
          onItemTap: () {
            Get.toNamed(
              Routes.result,
              arguments: {"childId": widget.childId, "result": result},
            );
          },
        ),
        if (index == (totalResults - 1) &&
            hasMoreResults &&
            hasMoreResultsInProgress)
          _buildResultDetailsShimmerLoadingContainer(),
        if (index == (totalResults - 1) &&
            hasMoreResults &&
            fetchMoreResultsFailure)
          Center(
            child: CupertinoButton(
              child: Text(Utils.getTranslatedLabel(retryKey)),
              onPressed: () {
                context.read<ResultsCubit>().fetchMoreResults(
                      useParentApi: context.read<AuthCubit>().isParent(),
                      childId: widget.childId,
                      sessionYearId: _selectedSessionYear?.id,
                    );
              },
            ),
          ),
      ],
    );
  }

  Widget buildOfflineResults() {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomRefreshIndicator(
        onRefreshCallback: () {
          if (context.read<ResultsCubit>().state is ResultsFetchSuccess) {
            fetchResults();
          }
        },
        displacment: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: Utils.getScrollViewBottomPadding(context),
            top: Utils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
            ),
          ),
          child: BlocBuilder<ResultsCubit, ResultsState>(
            builder: (context, state) {
              if (state is ResultsFetchSuccess) {
                return state.results.isNotEmpty
                    ? Column(
                        children: List.generate(
                          state.results.length,
                          (index) => index,
                        ).map((index) {
                          return _buildResultDetailsContainer(
                            result: state.results[index],
                            index: index,
                            totalResults: state.results.length,
                            hasMoreResults:
                                context.read<ResultsCubit>().hasMore(),
                            hasMoreResultsInProgress:
                                state.fetchMoreResultsInProgress,
                            fetchMoreResultsFailure:
                                state.moreResultsFetchError,
                          );
                        }).toList(),
                      )
                    : const Center(
                        child: NoDataContainer(titleKey: noResultPublishedKey),
                      );
              }
              if (state is ResultsFetchFailure) {
                return ErrorContainer(
                  errorMessageCode: state.errorMessage,
                  onTapRetry: () {
                    fetchResults();
                  },
                );
              }
              return Column(
                children: List.generate(
                  Utils.defaultShimmerLoadingContentCount,
                  (index) => _buildResultDetailsShimmerLoadingContainer(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  //Online Result
  Widget buildMySubjectsListContainer() {
    return BlocBuilder<StudentSubjectsAndSlidersCubit,
        StudentSubjectsAndSlidersState>(
      builder: (context, state) {
        return BlocBuilder<ResultTabSelectionCubit, ResultTabSelectionState>(
          bloc: context.read<ResultTabSelectionCubit>(),
          builder: (context, state) {
            return AssignmentsSubjectContainer(
              cubitAndState: "onlineResult",
              onTapSubject: (classSubjectId) {
                //fetch student online Result according to respected subjectId
                context
                    .read<ResultTabSelectionCubit>()
                    .changeResultFilterBySubjectId(classSubjectId);
                fetchOnlineResults();
              },
              selectedClassSubjectId: state.resultFilterByClassSubjectId,
              subjects: (widget.subjects != null)
                  ? widget.subjects! //from parent
                  : context
                      .read<StudentSubjectsAndSlidersCubit>()
                      .getSubjectsForAssignmentContainer(),
            );
          },
        );
      },
    );
  }

  void fetchOnlineResults() {
    context.read<ResultsOnlineCubit>().fetchResultsOnline(
          useParentApi: context.read<AuthCubit>().isParent(),
          childId: widget.childId ?? 0,
          classSubjectId: context
              .read<ResultTabSelectionCubit>()
              .state
              .resultFilterByClassSubjectId,
          sessionYearId: _selectedSessionYear?.id,
        );
  }

  Widget _buildOnlineResultDetailsContainer({
    required ResultOnline result,
    required int index,
    required int totalResults,
    required bool hasMoreResults,
    required bool hasMoreResultsInProgress,
    required bool fetchMoreResultsFailure,
  }) {
    if (index == (totalResults - 1)) {
      if (hasMoreResults) {
        if (hasMoreResultsInProgress) {
          return _buildResultDetailsShimmerLoadingContainer(); //same for both Online and Offline Result
        }
        if (fetchMoreResultsFailure) {
          return Center(
            child: CupertinoButton(
              child: Text(Utils.getTranslatedLabel(retryKey)),
              onPressed: () {
                context.read<ResultsOnlineCubit>().fetchMoreResultsOnline(
                      useParentApi: context.read<AuthCubit>().isParent(),
                      childId: widget.childId ?? 0,
                      classSubjectId: context
                          .read<ResultTabSelectionCubit>()
                          .state
                          .resultFilterByClassSubjectId,
                      sessionYearId: _selectedSessionYear?.id,
                    );
              },
            ),
          );
        }
      }
    }
    return ListItemForOnlineExamAndOnlineResult(
      isExamStarted: true,
      examStartingDate: result.examDate,
      examEndingDate: result.examDate,
      examName: result.examName,
      subjectName: result.subject.getSubjectName(context: context),
      totalMarks: result.totalMarks,
      marks: result.obtainedMarks,
      isSubjectSelected: (context
                  .read<ResultTabSelectionCubit>()
                  .state
                  .resultFilterByClassSubjectId !=
              0)
          ? true
          : false,
      onItemTap: () {
        Get.toNamed(
          Routes.resultOnline,
          arguments: {
            "examId": result.examId,
            "examName": result.examName,
            "subjectName": result.subject.getSubjectName(context: context),
            "childId": widget.childId,
          },
        );
      },
    );
  }

  Widget buildOnlineResults() {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomRefreshIndicator(
        onRefreshCallback: () {
          if (context.read<ResultsOnlineCubit>().state
              is ResultsOnlineFetchSuccess) {
            fetchOnlineResults();
          }
        },
        displacment: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: Utils.getScrollViewBottomPadding(context),
            top: Utils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
            ),
          ),
          child: Column(
            children: [
              buildMySubjectsListContainer(),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.035),
              ),
              BlocBuilder<ResultsOnlineCubit, ResultsOnlineState>(
                builder: (context, state) {
                  if (state is ResultsOnlineFetchSuccess) {
                    return state.results.isNotEmpty
                        ? Column(
                            children: List.generate(
                              state.results.length,
                              (index) => index,
                            ).map((index) {
                              return _buildOnlineResultDetailsContainer(
                                result: state.results[index],
                                index: index,
                                totalResults: state.results.length,
                                hasMoreResults: context
                                    .read<ResultsOnlineCubit>()
                                    .hasMore(),
                                hasMoreResultsInProgress:
                                    state.fetchMoreResultsOnlineInProgress,
                                fetchMoreResultsFailure:
                                    state.moreResultsOnlineFetchError,
                              );
                            }).toList(),
                          )
                        : const Center(
                            child: NoDataContainer(
                              titleKey: noResultPublishedKey,
                            ),
                          );
                  }
                  if (state is ResultsOnlineFetchFailure) {
                    return ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: () {
                        fetchOnlineResults();
                      },
                    );
                  }
                  return Column(
                    children: List.generate(
                      Utils.defaultShimmerLoadingContentCount,
                      (index) => _buildResultDetailsShimmerLoadingContainer(),
                    ),
                    //same for both Online and Offline Result
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SchoolSessionYearsCubit, SchoolSessionYearsState>(
      listener: (context, sessionState) {
        if (sessionState is SchoolSessionYearsFetchSuccess) {
          _sessionYears = sessionState.sessionYears;
          final defaultIndex =
              _sessionYears.indexWhere((e) => e.isDefault == 1);
          _selectedSessionYear = defaultIndex != -1
              ? _sessionYears[defaultIndex]
              : (_sessionYears.isNotEmpty ? _sessionYears.first : null);
          setState(() {});
          fetchResults();
          fetchOnlineResults();
        }
      },
      child: BlocBuilder<ResultTabSelectionCubit, ResultTabSelectionState>(
        builder: (context, state) {
          return Stack(
            children: [
              (context.read<ResultTabSelectionCubit>().isResultOnline())
                  ? buildOnlineResults()
                  : buildOfflineResults(),
              Align(
                alignment: Alignment.topCenter,
                child: _buildAppBar(state),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Private widget for session year filter bottom sheet.
class _SessionYearFilterSheet extends StatefulWidget {
  final List<SessionYear> sessionYears;
  final SessionYear? selectedSessionYear;
  final Function(SessionYear) onSessionYearSelected;

  const _SessionYearFilterSheet({
    required this.sessionYears,
    required this.selectedSessionYear,
    required this.onSessionYearSelected,
  });

  @override
  State<_SessionYearFilterSheet> createState() =>
      _SessionYearFilterSheetState();
}

class _SessionYearFilterSheetState extends State<_SessionYearFilterSheet> {
  late SessionYear? _currentlySelected = widget.selectedSessionYear;

  Widget _buildFilterTile({
    required String title,
    required SessionYear sessionYear,
  }) {
    final isSelected = _currentlySelected?.id == sessionYear.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentlySelected = sessionYear;
          });
          widget.onSessionYearSelected(sessionYear);
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.75,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (0.075),
        vertical: MediaQuery.of(context).size.height * (0.05),
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Utils.bottomSheetTopRadius),
          topRight: Radius.circular(Utils.bottomSheetTopRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTranslatedLabel(sessionYearKey),
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          ...widget.sessionYears.map(
            (sessionYear) => _buildFilterTile(
              title: sessionYear.name ?? '',
              sessionYear: sessionYear,
            ),
          ),
        ],
      ),
    );
  }
}
