import 'package:flutter/material.dart';
import 'package:rooted/models/daily_verse.dart';
import 'package:rooted/services/verse_service.dart';
import 'package:rooted/services/local_storage_service.dart';

class VerseArchiveScreen extends StatefulWidget {
  const VerseArchiveScreen({super.key});

  @override
  State<VerseArchiveScreen> createState() => _VerseArchiveScreenState();
}

class _VerseArchiveScreenState extends State<VerseArchiveScreen> {
  List<DailyVerse> _allVerses = [];
  List<DailyVerse> _filteredVerses = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date', 'reference', 'favorites'
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    setState(() => _isLoading = true);
    try {
      final allVerses = await LocalStorageService.getDailyVerses();
      setState(() {
        _allVerses = allVerses;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading verses: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<DailyVerse> filtered = List.from(_allVerses);

    // Filter by favorites
    if (_showFavoritesOnly) {
      filtered = filtered.where((v) => v.isFavorite).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((verse) {
        return verse.verse.toLowerCase().contains(query) ||
            verse.reference.toLowerCase().contains(query) ||
            (verse.reflection?.toLowerCase().contains(query) ?? false) ||
            verse.version.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => _sortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
        break;
      case 'reference':
        filtered.sort((a, b) => _sortAscending
            ? a.reference.compareTo(b.reference)
            : b.reference.compareTo(a.reference));
        break;
      case 'favorites':
        filtered.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return _sortAscending ? 1 : -1;
          if (!a.isFavorite && b.isFavorite) return _sortAscending ? -1 : 1;
          return _sortAscending
              ? a.date.compareTo(b.date)
              : b.date.compareTo(a.date);
        });
        break;
    }

    setState(() => _filteredVerses = filtered);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verse Archive'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
              _applyFilters();
            },
            tooltip: _showFavoritesOnly ? 'Show all verses' : 'Show favorites only',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search verses, references, or reflections...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
            ),
          ),

          // Filter and sort bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
                      DropdownMenuItem(value: 'reference', child: Text('Sort by Reference')),
                      DropdownMenuItem(value: 'favorites', child: Text('Sort by Favorites')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortBy = value);
                        _applyFilters();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() => _sortAscending = !_sortAscending);
                    _applyFilters();
                  },
                  tooltip: _sortAscending ? 'Ascending' : 'Descending',
                ),
              ],
            ),
          ),

          // Results count
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredVerses.length} ${_filteredVerses.length == 1 ? 'verse' : 'verses'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (_showFavoritesOnly) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: const Text('Favorites only'),
                      avatar: const Icon(Icons.favorite, size: 16),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            ),

          // Verses list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVerses.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadVerses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredVerses.length,
                          itemBuilder: (context, index) {
                            final verse = _filteredVerses[index];
                            return _VerseCard(
                              verse: verse,
                              onFavoriteToggle: () => _toggleFavorite(verse.id),
                              onReflectionTap: () => _showReflectionDialog(verse),
                              onDelete: () => _confirmDeleteVerse(verse),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showFavoritesOnly ? Icons.favorite_border : Icons.book_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _showFavoritesOnly
                ? 'No favorite verses yet'
                : _searchQuery.isNotEmpty
                    ? 'No verses found'
                    : 'No verses in archive',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _showFavoritesOnly
                ? 'Mark verses as favorites to see them here'
                : _searchQuery.isNotEmpty
                    ? 'Try adjusting your search terms'
                    : 'Verses will appear here as you add them',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(String verseId) async {
    await VerseService.toggleFavorite(verseId);
    await _loadVerses();
  }

  void _showReflectionDialog(DailyVerse verse) {
    final controller = TextEditingController(text: verse.reflection ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(verse.reference),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              verse.verse,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reflection',
                hintText: 'What does this verse mean to you?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await VerseService.addReflection(verse.id, controller.text);
              await _loadVerses();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteVerse(DailyVerse verse) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Verse'),
        content: const Text('Are you sure you want to remove this verse from the archive?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await LocalStorageService.deleteDailyVerse(verse.id);
        await _loadVerses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verse removed from archive')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting verse: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error deleting verse. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _VerseCard extends StatelessWidget {
  final DailyVerse verse;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onReflectionTap;
  final VoidCallback onDelete;

  const _VerseCard({
    required this.verse,
    required this.onFavoriteToggle,
    required this.onReflectionTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onReflectionTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with reference and favorite button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          verse.reference,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          verse.version,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      verse.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: verse.isFavorite ? Colors.red : null,
                    ),
                    onPressed: onFavoriteToggle,
                    tooltip: verse.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Verse text
              Text(
                verse.verse,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              ),
              
              // Reflection if exists
              if (verse.reflection != null && verse.reflection!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          verse.reflection!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Footer with date and actions
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(verse.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  if (verse.reflection == null || verse.reflection!.isEmpty)
                    TextButton.icon(
                      onPressed: onReflectionTap,
                      icon: const Icon(Icons.add_comment, size: 16),
                      label: const Text('Add reflection'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: theme.colorScheme.error,
                    onPressed: onDelete,
                    tooltip: 'Delete verse',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

