import React from 'react';
import PropTypes from 'prop-types';
import {withStyles} from 'material-ui/styles';
import GridList from 'material-ui/GridList';
import GridListTile from 'material-ui/GridList/GridListTile';
import GridListTileBar from 'material-ui/GridList/GridListTileBar';

const styles = theme => ({
    root: {
        display: 'flex',
        flexWrap: 'wrap',
        justifyContent: 'space-around',
        overflow: 'hidden',
        backgroundColor: theme.palette.background.paper,
    },
    gridList: {
        flexWrap: 'nowrap',
        // Promote the list into his own layer on Chrome. This cost memory but helps keeping high FPS.
        transform: 'translateZ(0)',
    },
    title: {
        color: theme.palette.primary.light,
    },
    titleBar: {
        background:
            'linear-gradient(to top, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.3) 70%, rgba(0,0,0,0) 100%)',
    },
});

/**
 * The example data is structured as follows:
 *
 * import image from 'path/to/image.jpg';
 * [etc...]
 *
 * const tileData = [
 *   {
 *     img: image,
 *     title: 'Image',
 *     author: 'author',
 *   },
 *   {
 *     [etc...]
 *   },
 * ];
 */
function SingleLineGridList(props) {
    const {classes} = props;

    return (
        <div className={classes.root}>
            <GridList className={classes.gridList} cols={3}>
                    <GridListTile key='amila'>
                        Amila
                        <GridListTileBar
                            title='Amila'
                            classes={{
                                root: classes.titleBar,
                                title: classes.title,
                            }}
                        />
                    </GridListTile>
                <GridListTile key='amila'>
                    Amila
                    <GridListTileBar
                        title='Amila'
                        classes={{
                            root: classes.titleBar,
                            title: classes.title,
                        }}
                    />
                </GridListTile>
                <GridListTile key='amila'>
                    Amila
                    <GridListTileBar
                        title='Amila'
                        classes={{
                            root: classes.titleBar,
                            title: classes.title,
                        }}
                    />
                </GridListTile>
            </GridList>
        </div>
    );
}

SingleLineGridList.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(SingleLineGridList);
